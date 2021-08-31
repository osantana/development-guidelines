#!/usr/bin/env python

import os

rootdir = os.path.abspath('..')

extensions = [
    'sphinx.ext.intersphinx',
    'sphinx.ext.todo',
    'sphinx.ext.mathjax',
    'sphinx.ext.ifconfig',
    'sphinx.ext.githubpages',
    'sphinxcontrib.plantuml',
]

templates_path = ['_templates']
source_suffix = ['.rst']
master_doc = 'index'

# General information about the project.
project = 'Development Guidelines'
copyright = '2021, Osvaldo Santana Neto'
author = 'Osvaldo Santana Neto'

version = '0.1'
release = '0.1.0'

language = None
exclude_patterns = []
pygments_style = 'sphinx'
todo_include_todos = True

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_sidebars = {
    '**': [
        'relations.html',  # needs 'show_related': True theme option to display
        'searchbox.html',
    ]
}

htmlhelp_basename = 'DevelopmentGuidelines'

latex_elements = {}
latex_documents = [
    (master_doc, 'DevelopmentGuidelines.tex', 'Development Guidelines', 'Osvaldo', 'manual'),
]

man_pages = [
    (master_doc, 'developmentguidelines', 'Development Guidelines', [author], 1)
]

texinfo_documents = [
    (
        master_doc,
        'DevelopmentGuidelines',
        'Development Guidelines',
        author,
        'DevelopmentGuidelines',
        'Guidelines for Software Development Projects',
        'Miscellaneous',
    ),
]

epub_title = project
epub_author = author
epub_publisher = author
epub_copyright = copyright
epub_exclude_files = ['search.html']

plantuml = f'java -jar {rootdir}/plantuml.jar'
plantuml_output_format = 'svg'
