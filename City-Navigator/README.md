# City Navigator

## Introduction
- experimantal/educational project
- Python Flask application exposing several REST API endpoints
- simplified model of Vienna public transport (all U-Bahn lines, plus single S-Bahn line) read from a JSON file
- journy plan calculation based on Dijkstra's shortest path algorithm, itineraries of the lines etc.
- Python 3.8


## API Endpoints
- `GET /means-of-transport`
- `GET /lines`
- `GET /lines/<means_of_transport>`
- `GET /line/<identifier>`
- `GET /journey-plan`, two query string parameters `start` and `destination`
- `GET /calculation-statistics`
- `GET /version`


## How to Start the Application
The following commands illustrate how to start the application. The one and only command line argument specifies the name of a JSON configuration file which specifies model definition to be used by the application.
```
# Windows
python application.py <json-config-file>

# Linux
python3 application.py <json-config-file>
```

The model definition can be read either from a local file system, or from an S3 bucket. The following snippet illustrates a configuration with model definition stored on a local file system. The `bucket` attribute has no value (it can even be omitted), and the `path` attribute specifies the path to the configuration file.
```json
{
    "bucket": null,
    "path": "model.json"
}
```

The following snippet illustrates a configuration with model definition stored in an S3 bucket. The `bucket` attribute specifies the name of the S3 bucket, the `path` attribute specifies the S3 object key of the configuration file.
```json
{
    "bucket": "city-navigator-config-store",
    "path": "model.json"
}
```

## Source Code Organization and Dependencies
As the application is comprised of just few Python source files, the source code is organized in a flat structure with all source files residing in the same directory.

Dependencies on other Python modules:
- [Library of Graph Algorithms for Python](https://github.com/Jardo72/python-graph-alg-lib) - TODO - https://pypi.org/project/python-graph-alg-lib/
- AWS SDK for Python


## Deployment to AWS
