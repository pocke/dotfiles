syn match goExtIfErr "\v^\s*if\s+err\s*\!\=\s*nil\s*\{\s*\_$\_.\s*return.+\_$\_.\s*\}" fold
hi def link goExtIfErr Comment
