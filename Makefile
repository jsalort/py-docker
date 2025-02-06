all:
	docker build -t jsalort/py:3.12 .
	docker tag jsalort/py:3.12 jsalort/py:latest

push:
	docker push jsalort/py:3.12
	docker push jsalort/py:latest
