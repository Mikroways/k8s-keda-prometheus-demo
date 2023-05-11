# Demo escalamiento usando Kubernetes

Este repositorio simplifica la creación de un cluster kind de las siguientes
caracterśiticas:

* Un master y dos nodos
* Un directorio `helmfile/` con diferentes productos listos y configurados para
  iniciar una poc de forma simplficada

## Requisitos

* direnv
* kind
* helmfile
* helm
* kustomize
* k6

## Instalación:

Correr en el siguiente orden:

```
kind create cluster --config kind-config.yaml
helmfile sync
kubectl apply -k application/
```

## Cómo probar

> Se asume las pruebas se desarrollan en Linux, donde el DNS empleado es
> hpa.mikroways.localhost. En Linux este dominio resolverá en 127.0.0.1

Una vez con los requerimientos instalados, podremos acceder a los servicios
instalados usando los siguientes enlaces:

* **[Grafana](http://hpa.mikroways.localhost/grafana):** usuario **admin** password
  **mikroways**. Es importante visualizar dos dashboards:
  * El del nginx ingress controller para el namespace webapp y con 5 segundos de
    refresh
  * El de pods por namespace para mostrar el escalamiento
* **[Aplicación de prueba](http://hpa.mikroways.localhost/webapp):** muestra el
  hostname del pod donde corre la aplicación. Al escalar el nombre irá
  cambiando.

## ¿Cuándo escalará la aplicación?

Si observamos la configuración de autoecalado basado en
[keda](https://keda.sh/), veremos que cuando se superan los 20 requerimientos
por segundo, se escala la aplicación. Pasados 30 segundos
sin esa carga se comienza a escalar hacia abajo. Puede verse esta configuración
en el [siguiente manifiesto](./application/resources/scaled-object.yaml).

Se recomienda dejar abierto un navegador con el dashboard de pods en el
namespace de webapp, y otro del nginx ingress de webapp. Además visualizar la
salida de:

```
kubectl -n webapp get hpa -w
```

## Estresando la aplicación

Usarmos k6 paraq estresar la aplicación. Primero probaremos una carga de 10
requerimientos constantes por 120 segundos, y veremos que no escala la
aplicación: 

```
k6 run --vus 10 --duration 120s script.js
```

> Observaremos que la cantidad de RPS no es suficiente para el escalado

Ahora con 50 requerimientos por segundo:

```
k6 run --vus 50 --duration 300s script.js
```

> Observaremos que la cantidad de RPS nos lleva a escalar a 3 los pods


Podemos probar una vez más con 150 requerimientos por segundo:

```
k6 run --vus 150 --duration 300s script.js
```
