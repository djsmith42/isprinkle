OUT_FILE=images_rc.py

${OUT_FILE}: images.qrc
	pyrcc4 $< -o $@

clean:
	rm -vf ${OUT_FILE}*
