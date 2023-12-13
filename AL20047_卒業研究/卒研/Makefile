all:	thesis.tex
	platex thesis.tex
	pbibtex thesis.aux
	platex thesis.tex
	platex thesis.tex
	dvipdfmx thesis.dvi

clean:	thesis.pdf
	rm thesis.pdf
	rm thesis.aux
	rm thesis.log
	rm thesis.dvi
	
