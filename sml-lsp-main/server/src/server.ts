import {
	createConnection,
	TextDocuments,
	ProposedFeatures,
	InitializeParams,
	DidChangeConfigurationNotification,
	CompletionItem,
	CompletionItemKind,
	TextDocumentSyncKind,
	InitializeResult,
	CompletionParams
} from 'vscode-languageserver/node';
import {
	diffChars
} from "diff";

import {
	TextDocument
} from 'vscode-languageserver-textdocument';

import {
	exec
} from 'child_process';
import {
	join,
} from 'path';

// コネクションを作成	
const connection = createConnection(ProposedFeatures.all);
// ドキュメントマネージャーを作成
const documents: TextDocuments<TextDocument> = new TextDocuments(TextDocument);

// 各種設定
let hasConfigurationCapability = false;
let hasWorkspaceFolderCapability = false;
let hasDiagnosticRelatedInformationCapability = false;

connection.onInitialize((params: InitializeParams) => {
	const capabilities = params.capabilities;

	hasConfigurationCapability = !!(
		capabilities.workspace && !!capabilities.workspace.configuration
	);
	hasWorkspaceFolderCapability = !!(
		capabilities.workspace && !!capabilities.workspace.workspaceFolders
	);
	hasDiagnosticRelatedInformationCapability = !!(
		capabilities.textDocument &&
		capabilities.textDocument.publishDiagnostics &&
		capabilities.textDocument.publishDiagnostics.relatedInformation
	);

	const result: InitializeResult = {
		capabilities: {
			textDocumentSync: TextDocumentSyncKind.Incremental,
			completionProvider: {
				resolveProvider: true
			}
		}
	};
	if (hasWorkspaceFolderCapability) {
		result.capabilities.workspace = {
			workspaceFolders: {
				supported: true
			}
		};
	}
	return result;
});

// 初期化時の実行内容
connection.onInitialized(() => {
	if (hasConfigurationCapability) {
		// Register for all configuration changes.
		connection.client.register(DidChangeConfigurationNotification.type, undefined);
	}
	if (hasWorkspaceFolderCapability) {
		connection.workspace.onDidChangeWorkspaceFolders(_event => {
			connection.console.log('Workspace folder change event received.');
		});
	}
});

/* 以下実装内容 */

// カーソル位置(offset)
let position = -1;
// 変更前のテキスト
let preContents = "";

// 補完候補を格納する配列
let completionItems: CompletionItem[];

// ドキュメントの変更が行われた際に実行
documents.onDidChangeContent(async change => {
	const results = diffChars(preContents, change.document.getText());
	if (results[0].count) {
		position = results[0].count + 1;
	}
	// 変更前のドキュメントに変更が行われたところ代入
	preContents = change.document.getText();

	completionItems = [];
	const execBuf = exec(`${join(__dirname, 'parse')} ${position}`, (err, stdout, stderr) => {
		//変更候補をcandidatesに格納		
		const candidates: CompletionItem[] = [];
		try {
			// 実行結果から構文木を取得，JSON化
			const parseTree = JSON.parse(stdout);
			console.log(JSON.stringify(parseTree, null, 2));

			// スコープを考慮した補完候補の取得
			// searchScopeTokenに補完候補を代入
			const searchScopeToken: any = (tree: any, tokens: string[]) => {
				switch (tree.tag) {
					case "START":
						return searchScopeToken(tree["exp"], []);
					case "EXP1":
						return searchScopeToken(tree["appexp"], tokens);
					case "EXP2":
						return searchScopeToken(tree["exp"], tokens);
					case "APPEXP1":
						return searchScopeToken(tree["atexp"], tokens);
					case "APPEXP2":
						{
							const [token1, flag] = searchScopeToken(tree["appexp"], tokens);
							// APPEXPにIDCURSORが存在したとき
							if (!flag) {
								return [token1, flag];
							} else {
								const [token2, flag] = searchScopeToken(tree["atexp"], token1);
								// ATEXPにIDCURSORが存在したとき
								if (!flag) {
									return [token2, flag];
								} else {
									return [token1, flag];
								}
							}	
						}
					case "ATEXP1_2":
						return [tokens, false];
					case "ATEXP8":
						return searchScopeToken(tree["dec"], tokens);
					case "DEC300":
						return searchScopeToken(tree["patset"], tokens);
					case "PATSET":
						{
							tokens.push(tree["id"]);
							return searchScopeToken(tree["pat"], tokens);
						}
					case "PAT":
						{
							tokens.push(tree["id"]);
							tokens = ["("+tokens[0]+","+tokens[1]+")"];
							return [tokens, true];
						}
					case "DEC500":
						{
							tokens.push(tree["args"]);
							return [tokens, true];
						}
					case "DEC1":
						{
							const [token1, flag] = searchScopeToken(tree["exp"], tokens);
							if (!flag) return [token1, flag];
							else {
								token1.push(tree["id"]);
								return [token1, flag];
							}
						}
					case "DEC3":
						{
							tokens.push(tree["id"]);
							return [tokens, true];
						}
					case "DEC4":
						{
							const [token1, flag] = searchScopeToken(tree["exp"], tokens);
							if (!flag) return [token1, flag];
							else {
								token1.push(tree["id"]);
								return [token1, flag];
							}
						}
					case "DEC5":
						{
							tokens.push(tree["id"]);
							return [tokens, true];
						}
					default:
						return [tokens, true];
					}
				}
			
			// const result = searchScopeToken(parseTree, [])[0];
			const result =searchScopeToken(parseTree, [])[0];
			console.log(result);
			result
				.forEach((e: string) => {
					candidates.push({
						label: e,
						kind: CompletionItemKind.Variable,
					})
				});
			
		} catch (e) {
			console.log(e);
			console.log('構文解析に失敗しました');
			return -1;
		} finally {
			candidates.push(
				{ label: 'let', kind: CompletionItemKind.Keyword, data: 'let' },
				{ label: 'val', kind: CompletionItemKind.Keyword, data: 'val' },
				{ label: 'in', kind: CompletionItemKind.Keyword, data: 'in' },
				{ label: 'end', kind: CompletionItemKind.Keyword, data: 'end' },
			);
			
			completionItems =candidates;
		}
	});
	execBuf.stdin?.write(change.document.getText());
	execBuf.stdin?.end();
});

// 補完される際に実行
connection.onCompletion(
	(params: CompletionParams): CompletionItem[] =>  {
		// 補完候補があれば返す
		if (completionItems && completionItems.length > 0) {
			return completionItems;
		}
		return [];
		
	}
);

connection.onCompletionResolve(
	(item: CompletionItem): CompletionItem => {
		if (item.data === 1) {
			item.detail = 'TypeScript details';
			item.documentation = 'TypeScript documentation';
		} else if (item.data === 2) {
			item.detail = 'JavaScript details';
			item.documentation = 'JavaScript documentation';
		}
		return item;
	}
);

// ドキュメントイベント(内容の変更やファイルの開閉等)を監視
documents.listen(connection);

// 接続を監視
connection.listen();
