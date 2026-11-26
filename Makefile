PHONY_TARGETS := compile view
.PHONY: $(PHONY_TARGETS)

all:
	@printf '%s\n' $(PHONY_TARGETS) | fzf | xargs -r make

compile:
	mkdir -p build/
	luajit src/parser.lua --no-table > /tmp/the-dumpster-pdf.md
	pandoc /tmp/the-dumpster-pdf.md \
		-f markdown -t pdf \
		-o build/the-dumpster.pdf \
		--pdf-engine=xelatex \
		-V 'mainfont:NotoSerif-Regular.ttf' \
		-V 'mainfontoptions:BoldFont=NotoSerif-Bold.ttf, ItalicFont=NotoSerif-Italic.ttf, BoldItalicFont=NotoSerif-BoldItalic.ttf' \
		-V geometry:margin=1cm \
		-V fontsize=8pt

view:
	zathura build/the-dumpster.pdf & disown
