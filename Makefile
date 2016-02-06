HACKED_UP_DEPS = aeson/ criterion/ vector-th-unbox/

.PHONY: criterion

criterion:
	git submodule update --init
	cabal sandbox delete
	cabal clean
	cabal sandbox init
	cabal sandbox add-source $(HACKED_UP_DEPS)
	cabal install criterion --allow-newer
