# Converts source notebooks in directories to the release versions like:
# *source/* => *release/*

# NBS: notebooks
NBGRADER_SOURCE_NBS = $(wildcard *source/*/*.ipynb)
# Some notebooks may carry additional files.
NBGRADER_SOURCE_ALL = $(wildcard *source/*/*.*)
NBGRADER_SOURCE_NOT_NBS = $(filter-out $(NBGRADER_SOURCE_ALL),$(NBGRADER_SOURCE_NBS))
NBGRADER_SOURCE_DIRS = $(sort $(dir $(wildcard *source/*/*.ipynb)))

TARGET_FILES = $(subst source,release,$(NBGRADER_SOURCE_ALL))

all: $(TARGET_FILES)

define ipynb_conversion_for_every_dir
# notebooks
$(subst source,release,$1)%.ipynb: $1%.ipynb
	@mkdir -p $$(@D)
	jupyter-nbconvert \
		--Exporter.preprocessors=nbgrader.preprocessors.LockCells \
		--Exporter.preprocessors=nbgrader.preprocessors.ClearSolutions \
		--Exporter.preprocessors=nbgrader.preprocessors.ClearOutput \
		--Exporter.preprocessors=nbgrader.preprocessors.CheckCellMetadata \
		--Exporter.preprocessors=nbgrader.preprocessors.ClearHiddenTests \
		--Exporter.preprocessors=nbgrader.preprocessors.ClearMarkScheme \
		--Exporter.preprocessors=nbgrader.preprocessors.ComputeChecksums \
		--stdout \
		--to ipynb \
		$$< \
		> $$@ 

# auxiliary files that only need to be copied
$(subst source,release,$1)%: $1%
	@mkdir -p $$(@D)
	cp $$< $$@
endef
$(foreach d,$(NBGRADER_SOURCE_DIRS),$(eval $(call ipynb_conversion_for_every_dir,$d)))
ifdef DEBUG
$(info ====Created Rules:====)
$(foreach d,$(NBGRADER_SOURCE_DIRS),$(info $(call ipynb_conversion_for_every_dir,$d)))
endif

clean:
	$(RM) -r *-release
