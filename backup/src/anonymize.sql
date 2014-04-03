
DELETE FROM USERPARAMETER WHERE Container_Resourceuri NOT LIKE '%/super' AND Container_Resourceuri NOT LIKE '%/sixsq' AND Container_Resourceuri NOT LIKE '%/test';
DELETE FROM USER WHERE Name <> 'super' AND Name <> 'sixsq' AND Name <> 'test';

DELETE FROM CLOUDIMAGEIDENTIFIER WHERE Container_Resourceuri NOT LIKE 'module/examples/%';

UPDATE MODULE SET Authz_Id=Null, Commit_Id=Null WHERE Resourceuri NOT LIKE 'module/examples/%';

DELETE FROM AUTHZ WHERE Guardedmodule_resourceuri NOT LIKE 'module/examples/%';
DELETE FROM COMMIT WHERE Guardedmodule_resourceuri NOT LIKE 'module/examples/%';

DELETE FROM MODULE_TARGET WHERE Module_Resourceuri NOT LIKE 'module/examples/%';
DELETE FROM TARGET WHERE Id IN (SELECT Id FROM MODULE_TARGET RIGHT JOIN TARGET ON Targets_Id = Id WHERE Module_Resourceuri IS NULL);

DELETE FROM MODULE_PACKAGE WHERE Module_Resourceuri NOT LIKE 'module/examples/%';
DELETE FROM PACKAGE WHERE Id IN (SELECT Id FROM MODULE_PACKAGE RIGHT JOIN PACKAGE ON Packages_Id = Id WHERE Module_Resourceuri IS NULL);

DELETE FROM MODULE_NODE WHERE Module_Resourceuri NOT LIKE 'module/examples/%';
DELETE FROM NODEPARAMETER WHERE Container_Id IS NULL;
DELETE FROM NODEPARAMETER WHERE Container_Id IN (SELECT Id FROM NODE WHERE Imageuri NOT LIKE 'module/examples/%');
DELETE FROM NODE WHERE Imageuri NOT LIKE 'module/examples/%';

DELETE FROM MODULEPARAMETER WHERE Container_Resourceuri NOT LIKE 'module/examples/%';

DELETE FROM MODULE WHERE Resourceuri NOT LIKE 'module/examples/%';

DELETE FROM RUNPARAMETER;
DELETE FROM RUNTIMEPARAMETER;
DELETE FROM RUN;

DELETE FROM VM;

