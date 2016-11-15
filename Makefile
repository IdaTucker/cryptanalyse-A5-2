REPORT = Memoire.tex

.PHONY : clean all build help

all : report

report:
	@pdflatex $(REPORT)

clean :
	@rm -f *~ *.aux *.out *.log

help :
	@echo "Makefile usage :" 
	@echo "- make [all]  Create the report"
	@echo "- make report Create the report"
	@echo "- make clean  Remove all files generated for the report (pdf not included)"
	@echo "- make help   Display this help"
