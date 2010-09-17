OUT_DIR=generated
UI_FILES=\
		 ${OUT_DIR}/mainwidget.py

all: ${OUT_DIR} ${UI_FILES}

clean:
	rm -vf ${UI_FILES}
	rm -vf ${OUT_DIR}/*.pyc
	rm -vf ${OUT_DIR}/*.pyo
	rm -rvf ${OUT_DIR}

${OUT_DIR}:
	mkdir ${OUT_DIR}

${OUT_DIR}/%.py: %.ui
	pyuic4 $< -o $@ 
