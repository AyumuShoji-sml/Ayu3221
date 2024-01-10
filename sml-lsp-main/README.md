# SML-LSP
Standard MLのLanguage Server

## 環境構築
### Windowsの場合
[WSLのインストール](https://learn.microsoft.com/ja-jp/windows/wsl/install)が必要です。

併せてVSCodeの[WSL拡張機能のインストール](https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-vscode)も行ってください。

### Linuxの場合
そのまま実行してください

### macの場合
未検証

## インストール・実行方法
1. 各種インストール（インストール済みであれば省略可）
```bash
sudo apt update
sudo apt install -y build-essential git nodejs bison flex
```
2. リポジトリをクローン
```bash
git clone https://github.com/rom6621/sml-lsp.git
```
3. ディレクトリ移動
```bash
cd sml-lsp
```
4. makeコマンドでビルドを行う
```bash
make
```
5. VS Codeでダウンロードしたディレクトリを開く
```bash
code .
```
6. F5キーを押してデバッグモードを実行
7. 拡張子が`.sml`の適当なファイルを開く

### 構文解析結果の確認方法
1. VS Code ツールバーの「ターミナル」→「新しいターミナル」によりターミナルを開く
2. 表示されたターミナルのタブを「出力」に切り替え
3. 右上の「タスク」となっているプルダウンメニューを「Language Server Example」に切り替え
4. `.sml`形式のファイルを開いている時に限り、ファイルの編集が行われる度に構文解析の結果が表示されます
