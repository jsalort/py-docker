all:
	docker build -t jsalort/py:3.8 .
	docker tag jsalort/py:3.8 jsalort/py:latest

push:
	docker push jsalort/py:3.8
	docker push jsalort/py:latest