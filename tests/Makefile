all: test

test:
	@echo "Building host-side test harness..."
	@g++ -std=c++17 -Itests/include tests/test_placeholder.cpp -o tests/test_placeholder || true

run: test
	@echo "Running tests (placeholder)"
	@./tests/test_placeholder || true

clean:
	@rm -f tests/test_placeholder
