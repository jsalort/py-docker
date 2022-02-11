all:
	docker build --platform x86_64 -t jsalort/py:3.9 .
	docker tag jsalort/py:3.9 jsalort/py:latest

push:
	docker push jsalort/py:3.9
	docker push jsalort/py:latest
