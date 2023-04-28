# Architecture Documentation - images and UML diagrams

This subdirectory contains all images and UML diagrams for Architecture Documentation.

[UMLet][umlet] and [PlantUML][plantuml] diagrams are supported.
These diagrams are automatically generated in SVG and placed at the same place where the diagram source is located.

The ```uml``` directory contains configuration and templates for [UMLet][umlet] ans [PlantUML][plantuml] diagrams.

Images and UML diagrams must be organized into subdirectories for each dokumentation.
The subdirectory name follows the name of the documentation like ```Architecture_Documentation```.
UML diagrams are placed in the subdirectory ```uml``` and all other images are placed directly in this folder.

## Umlet

UMLet diagrams should be stored with the file name extension ```.uxf```.

Each UMLet diagram must be contain a copyright notice: ```(c) YYYY iteratec GmbH``` like the template contains one.

UMLet doesn't support includes or templates. Any diagram file must be follow the UMLet template ```uml/_umlet_template.uxf```.
There are following known issues:

1. The global configured ```fontsize``` will not inherited on elements. The ```fontsize``` must be configured on every element that contains text.
1. The diagram must be saved with zoom level 100%.

## PlantUML

PlantUML diagrams should be stored with the file name extension ```.puml```.
Files with the file name extension ```.ipuml``` are not PlantUML diagrams but files to include into PlantUML diagrams.

Each PlantUML diagram must include the copyright notice from ```uml/_copyright.ipuml```:

```text
@startuml
!include ../../uml/_copyright.ipuml
...
```

and the iteratec GmbH theme/branding ```uml/_iteratec_theme.ipuml```:

```text
!include ../../uml/_iteratecTheme.ipuml
...
```

[umlet]:        https://www.umlet.com/
[plantuml]:     http://plantuml.com/
[asciidoctor]:  https://www.asciidoctor.org
