# Example API
Example API description

## Version: 0.1.0

---
## status

### /status

#### GET
##### Summary

Get status

##### Description

Get status of the server

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

---
## device

### /device

#### POST
##### Summary

Create a device

##### Description

Create a device

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

### /device/{id}/recording

#### POST
##### Summary

Add recording data

##### Description

Add recording data

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

### /device/{id}/sensorData

#### POST
##### Summary

Add sensor data

##### Description

Add sensor data

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

### /device/{id}/recordings

#### GET
##### Summary

Get recordings

##### Description

Get recordings

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

### /device/{id}

#### DELETE
##### Summary

Delete a device

##### Description

Delete a device

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

#### GET
##### Summary

Get a device

##### Description

Get a device

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

#### POST
##### Summary

Create a device

##### Description

Create a device

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| id | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

---
## recording

### /recording/{recordingId}

#### GET
##### Summary

Get sensor data for recording

##### Description

Get sensor data for recording

##### Parameters

| Name | Located in | Description | Required | Schema |
| ---- | ---------- | ----------- | -------- | ------ |
| recordingId | path |  | Yes | string |

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |

---
## devices

### /devices

#### GET
##### Summary

Get all devices

##### Description

Get all devices

##### Responses

| Code | Description |
| ---- | ----------- |
| 200 | OK |
