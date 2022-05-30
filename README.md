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

## Pasos

Primero creamos el cluster kind:

```
kind create cluster --config kind-config.yaml
```

Luego, configuramos los servicios necesarios:

```
./requirements/install.sh
```
> Es **importante** leer los values de `requirements/metallb/metallb.yaml`
> porque en él se define la IP donde se exponen los servicios del cluster de
> kubernetes.

Antes de proceder agregar en el archivo `/etc/hosts` el siguiente contenido:

```
172.18.255.200 hpa.mikroways.demo
```
> La IP utilizada depende de la configuración de docker, por ello está
> relacionado con el valor seteado en metallb.

Ahora debemos proceder con la instalación de una aplicación web de prueba:

```
kubectl apply -k application/
```

Una vez con los requerimientos instalados, podremos acceder a los servicios
instalados usando los siguientes enlaces:

* **[Grafana](http://hpa.mikroways.demo/grafana):** usuario **admin** password
  **mikroways**. Es importante visualizar dos dashboards:
  * El del nginx ingress controller para el namespace webapp y con 5 segundos de
    refresh
  * El de pods por namespace para mostrar el escalamiento
* **[Aplicación de prueba](http://hpa.mikroways.demo/webapp):** muestra el
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
k6 run --vus 50 --duration 120s script.js
```

> Observaremos que la cantidad de RPS nos lleva a escalar a 3 los pods

Ahora con 50 requerimientos por segundo:

```
k6 run --vus 50 --duration 120s script.js
```

> Observaremos que la cantidad de RPS nos lleva a escalar a 3 los pods

Podemos probar una vez más con 150 requerimientos por segundo:

```
k6 run --vus 150 --duration 120s script.js
```
