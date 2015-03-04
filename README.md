#RDB

Easy-cheezy classes for synchronizing your models with REST service.    

## How it works

1. RDBObject returns RDBRequestModel configured for the operation you want to perform:     
`+/- (RDBRequestModel *)requestModelWithOperation:(RDBOperation)operation;`
2. RDB executes the model by forging appropriate HTTP request:     
`- (void)executeRequestModel:(RDBRequestModel *)model withResponseBlock:(RDBResponseBlock)responseBlock;`
3. Response block provides RDBResponse with HTTP statusCode, unparsed responseObject, parsed/updated object (either your model or array of models).

RDBObject+Helpers category makes it really easy to create/update/get/delete models.    
Simple example of fetching Task with `522e362906aef932e1714df9` id.    
```[KLTask withID:@"522e362906aef932e1714df9" withResponseBlock:^(RDBResponse *response) {...}];```

## Configure: the easy way
    
Connect your model with REST API in 5 easy steps:

1. Configure sharedInstance of `[RDB sharedDB]` by setting url and postfix, eg url: http://localhost:8000, postfix: api/v1/    
2. Make your model inherit from RDBObject.
3. Implement `+ (NSString*)RESTPath;` method returning objects' HTTP path, eg `+ (NSString*)RESTPath { return @"tasks"; }`
4. Implement `+ (NSDictionary*)jsonKeyPathToClassMapping;` with your mappings.
5. Import RDBObject+Helpers and call `[YourModel allWithResponseBlock:^(RDBResponse *response) {...}]`

## Configure: the customizable way

### RDB Class

You can configure behaviour that will be applied to all requests being performed and to further parsing.     
List of configurable instance properties:

* **NSURL \*url**    
Service base URL eg http://localhost:8080

* **NSString \*urlPostfix**    
Everything that comes after base URL and before the model name eg api/v1/

* **NSString \*jsonMetaKeyPath, \*jsonObjectKeyPath, \*jsonObjectsKeyPath**    
JSON keypathes that can be applied to every response.
	* Meta - response metadata, defaults to "meta"
	* Object - keypath of the object when performing instance GET operation, defaults to ""
	* Objects - keypath of the array of objects when performing class GET operation, defaults to "objects"     

* **HTTPMethod operationGetMethod, operationUpdateMethod, operationDeleteMethod, operationCreateMethod**    
RDB has only 4 basic model operations. Associated HTTP request types can be customized with those properties. Defaults to: GET, PATCH, DELETE and POST.

* **NSDictionary \*HTTPHeaders**     
HTTP Headers being attached to every request performed by RDB

### RDBObject Class / RDBObject Protocol

RDBObject or its descendants can be configured by implementing proper methods. Instance `-` methods are being called when RDBRequestModel is being created from instance, otherwise class `+` methods are being used.

* **(RDB \*)db**    
Implement if you don't want to use default sharedDB.

Legacy methods from RDB 1.0, can be easily used when you are satisfied with default behaviours.    

* **+ (NSString\*)RESTPath**    
Models' HTTP URL path. Used when constructing urls:
	* get all / create new: {RDB.url}/{RDB.postfix}/{Model.RESTPath}
	* get / delete / update one with id: {RDB.url}/{RDB.postfix}/{Model.RESTPath}/{Instance._id}

* **(NSString\*)jsonObjectKeyPath**    
In case dictionary we want to use to populate the fields is somewhere inside the JSONs tree, we might specify distinct keypath.

* **(NSString\*)jsonObjectsKeyPath**    
The same as above but applies to the results with many objects being returned (get all).

* **(NSDictionary\*)jsonKeyPathToAttributesMapping**     
Dictionary with mapping json keypath -> model keypath. Example dictionary `@{"title":"title", "related.children[0]":"firstChild"}`

* **(NSDictionary\*)jsonKeyPathToClassMapping**    
Sometimes NSArray is one of the models' properties. In this situation class of the object inside have to be specified. Example dictionary `@{"arrayOfSubmodels":[Submodel class]}`

Methods below have been introduced in RDB 2.0 and can be implemented in case we want full control over how RDBRequestModel is being created. You can implement `requestModelWithOperation` to create whole object manually or use methods below for customizing only part of the requestModel.

* **(RDBRequestModel \*)requestModelWithOperation:(RDBOperation)operation**     
Uses methods below to create requestModel.

* **(NSString \*)pathWithRequestModel:(RDBRequestModel \*)requestModel**     
Depending on requestModel.operation returns proper HTTP path.

* **(HTTPMethod)methodWithRequestModel:(RDBRequestModel \*)requestModel**     
Depending on requestModel.operation returns proper HTTP method.

* **(NSDictionary \*)headersWithRequestModel:(RDBRequestModel \*)requestModel**     
Returns additional headers we may want to include in the request.

* **(id)requestObjectWithRequestModel:(RDBRequestModel \*)requestModel**     
Returns JSON object. When updating / creating object we need to attach instance object to the HTTP request.

JSON related operations.    

* **+ (instancetype)instanceWithDictionary:(NSDictionary \*)dictionary**
* **- (instancetype)initWithDictionary:(NSDictionary \*)dictionary**
* **- (NSDictionary \*)dictionaryRepresentation**
* **- (void)patchWithDictionary:(NSDictionary \*)dict**

In case you want perform some operations before/after RDBRequestModel representing this class is executed, you can implement those two methods.    

* **- (void)requestModelWillStartExecuting:(RDBRequestModel \*)requestModel**    
* **- (void)requestModelDidFinishExecuting:(RDBRequestModel \*)requestModel**    

## License
MIT. Fork it, work it, make it, do it.