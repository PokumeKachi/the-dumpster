all:
	luajit src/parser.lua > build/the-dumpster.md
	luajit src/parser.lua --no-table > the-dumpster-pdf.md
	pandoc the-dumpster-pdf.md \
		-f markdown -t pdf \
		-o build/the-dumpster.pdf \
		--pdf-engine=xelatex \
		-V 'mainfont:NotoSerif-Regular.ttf' \
		-V 'mainfontoptions:BoldFont=NotoSerif-Bold.ttf, ItalicFont=NotoSerif-Italic.ttf, BoldItalicFont=NotoSerif-BoldItalic.ttf' \
		-V geometry:margin=1cm \
		-V fontsize=8pt
	rm the-dumpster-pdf.md

git:
	git commit -a
	git push
