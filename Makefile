PHONY_TARGETS := compile git todo flake-develop
.PHONY: $(PHONY_TARGETS)

all:
	@printf '%s\n' $(PHONY_TARGETS) | fzf | xargs -r make

flake-develop:
	@bash -c '\
		h=$$(nix hash path ./flake.nix); \
		if [ "$$FLAKE_HASH" != "$$h" ]; then \
			FLAKE_HASH=$$h exec nix develop; \
			exit 1;\
		else \
			echo "FLAKE_HASH=$$FLAKE_HASH OK"; \
		fi'

compile: flake-develop
	# luajit src/parser.lua > build/the-dumpster.md
	luajit src/parser.lua --no-table > /tmp/the-dumpster-pdf.md
	pandoc /tmp/the-dumpster-pdf.md \
		-f markdown -t pdf \
		-o build/the-dumpster.pdf \
		--pdf-engine=xelatex \
		-V 'mainfont:NotoSerif-Regular.ttf' \
		-V 'mainfontoptions:BoldFont=NotoSerif-Bold.ttf, ItalicFont=NotoSerif-Italic.ttf, BoldItalicFont=NotoSerif-BoldItalic.ttf' \
		-V geometry:margin=1cm \
		-V fontsize=8pt

git:
	git add .
	git commit
	git push

todo:
	taskwarrior-tui --taskdata .tasks
