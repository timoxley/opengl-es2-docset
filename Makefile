REMOTE := https://www.khronos.org/opengles/sdk/docs/man/xhtml
DOCSET := opengles.docset
CONTENTS := $(DOCSET)/Contents
DOCUMENTS := $(CONTENTS)/Resources/Documents
WGET := wget -N -nd -r --quiet --progress=dot --show-progress --span-hosts --convert-links --page-requisites --reject=*robots.txt --directory-prefix=$(DOCUMENTS)
DB := $(CONTENTS)/Resources/docSet.dsidx

DEP_FILES := index.html mathml.xsl xhtml1-transitional.dtd xhtml-lat1.ent xhtml-symbol.ent xhtml-special.ent ctop.xsl pmathml.xsl
DEPS_SRC := $(addprefix $(REMOTE)/,$(DEP_FILES))
DEPS_DEST := $(addprefix $(DOCUMENTS)/,$(DEP_FILES))

all: docs $(DB)

docs: $(DOCUMENTS)/style.css $(CONTENTS)/Info.plist $(DOCSET)/icon.png $(DEPS_DEST) | $(DOCUMENTS)
	$(MAKE) rename

$(DEPS_DEST):
	$(WGET) $(REMOTE)/$(notdir $@)

$(DOCUMENTS):
	-mkdir -p $@

$(DOCUMENTS)/style.css: style.css
	-mkdir -p $(dir $@)
	cp -rfp style.css $@

$(CONTENTS)/Info.plist: Info.plist
	-mkdir -p $(dir $@)
	cp -rfp Info.plist $@

$(DOCSET)/icon.png: icon.png
	-mkdir -p $(dir $@)
	cp -rfp icon.png $@

$(DB): $(DOCUMENTS)/index.html parse.js populate.js package.json
	rm -rf $(DB)
	sqlite3 $(DB) "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT); CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"
	node parse.js | node populate.js | sqlite3 $(DB)

db: clean-db
	$(MAKE) $(DB)

rename:
	sed -i.bak 's/V1.78.1" \/><\/head>/V1.78.1" \/><link rel="stylesheet" href="style.css" \/><\/head>/g' $(DOCUMENTS)/*.xml
	sed -i.bak 's/<style type="text\/css">/<link rel="stylesheet" href="style.css" \/><style type="text\/css">/g' $(DOCUMENTS)/index.html
	rm $(DOCUMENTS)/*.bak

clean:
	rm -rf opengles.docset

clean-db:
	rm -rf $(DB)

.PHONY: all docs db rename clean clean-db

