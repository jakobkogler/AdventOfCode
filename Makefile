%.a: %.d
	dmd -lib $< $(DFLAGS)

%.run: %.d $(DEPS)
	dmd $< $(DEPS) -of=$@ $(DFLAGS)

clean:
	rm *.run *.a -f
