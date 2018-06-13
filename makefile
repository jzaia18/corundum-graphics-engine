all: Main.rb clean
	ruby Main.rb script.mdl

clean:
	rm -f *~ *.ppm *.png *.gif anim/*.png parsetab.py parser.out
