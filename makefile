all: Main.rb clean
	ruby Main.rb

clean:
	rm -f *~ *.ppm *.png *.gif anim/*.png parsetab.py parser.out
