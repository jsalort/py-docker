all:
	docker build -t jsalort/py:3.14 .
	docker tag jsalort/py:3.14 jsalort/py:latest

push:
	docker push jsalort/py:3.14
	docker push jsalort/py:latest
