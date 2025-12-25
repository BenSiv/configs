.DELETE_ON_ERROR:
SCM_FILES = system.scm home.scm

all: $(SCM_FILES)

%.scm: %.wisp
	guile wisp_converter.guile < $< > $@

clean:
	rm -f $(SCM_FILES)
