from setuptools import setup, find_packages

setup(
    name="sascctl",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "typer",
        "pyyaml",
    ],
    entry_points={
        "console_scripts": [
            "sascctl = sascctl.main:app",
        ],
    },
)