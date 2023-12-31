-- DROP TABLE uinotification CASCADE CONSTRAINTS;


PROMPT Creating Table uinotification ...
CREATE TABLE uinotification (
  objectid VARCHAR2(38 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  notificationType VARCHAR2(255 CHAR) NOT NULL,
  createDate VARCHAR2(38 CHAR) NOT NULL,
  message VARCHAR2(4000 CHAR) NOT NULL,
  requester VARCHAR2(255 CHAR),
  receiverId VARCHAR2(255 CHAR) NOT NULL,
  requesterId VARCHAR2(255 CHAR),
  notificationSubtype VARCHAR2(255 CHAR)
);

PROMPT Creating Primary Key Constraint PRIMARY_0 on table uinotification ...
ALTER TABLE uinotification
ADD CONSTRAINT PRIMARY_0 PRIMARY KEY
(
  objectid
)
ENABLE
;

PROMPT Creating Index idx_uinotification_receiverId on uinotification ...
CREATE INDEX idx_uinotification_receiverId ON uinotification
(
  receiverId
)
;

-- DROP TABLE configobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table configobjectproperties ...
CREATE TABLE configobjectproperties (
  configobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(255 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_configobjectproperties_conf on configobjectproperties ...
CREATE INDEX fk_configobjectproperties_conf ON configobjectproperties
(
  configobjects_id
)
;
PROMPT Creating Index idx_configobjectpropert_1 on configobjectproperties ...
CREATE INDEX idx_configobjectpropert_1 ON configobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_configobjectpropert_2 on configobjectproperties ...
CREATE INDEX idx_configobjectpropert_2 ON configobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_15 on table configobjectproperties ...
ALTER TABLE configobjectproperties
ADD CONSTRAINT PRIMARY_15 PRIMARY KEY
(
  configobjects_id,
  propkey,
  propindex
)
;

-- DROP TABLE configobjects CASCADE CONSTRAINTS;


PROMPT Creating Table configobjects ...
CREATE TABLE configobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_3 on table configobjects ...
ALTER TABLE configobjects
ADD CONSTRAINT PRIMARY_3 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_configobjects_object on configobjects...
CREATE UNIQUE INDEX idx_configobjects_object ON configobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_configobjects_objecttypes on configobjects ...
CREATE INDEX fk_configobjects_objecttypes ON configobjects
(
  objecttypes_id
)
;

-- DROP TABLE notificationobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table notificationobjectproperties ...
CREATE TABLE notificationobjectproperties (
  notificationobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(255 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_notificationproperties_conf on notificationobjectproperties ...
CREATE INDEX fk_notificationproperties_conf ON notificationobjectproperties
(
  notificationobjects_id
)
;
PROMPT Creating Index idx_notificationproperties_1 on notificationobjectproperties ...
CREATE INDEX idx_notificationproperties_1 ON notificationobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_notificationproperties_2 on notificationobjectproperties ...
CREATE INDEX idx_notificationproperties_2 ON notificationobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_24 on table notificationobjectproperties ...
ALTER TABLE notificationobjectproperties
ADD CONSTRAINT PRIMARY_24 PRIMARY KEY
(
  notificationobjects_id,
  propkey,
  propindex
)
;

-- DROP TABLE notificationobjects CASCADE CONSTRAINTS;


PROMPT Creating Table notificationobjects ...
CREATE TABLE notificationobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_25 on table notificationobjects ...
ALTER TABLE notificationobjects
ADD CONSTRAINT PRIMARY_25 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_notificationobjects_object on notificationobjects...
CREATE UNIQUE INDEX idx_notificationobjects_object ON notificationobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_notification_objecttypes on notificationobjects ...
CREATE INDEX fk_notification_objecttypes ON notificationobjects
(
  objecttypes_id
)
;

-- DROP TABLE relationships CASCADE CONSTRAINTS;


PROMPT Creating Table relationships ...
CREATE TABLE relationships (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB,
  firstresourcecollection VARCHAR2(255 CHAR),
  firstresourceid VARCHAR2(56 CHAR),
  firstpropertyname VARCHAR2(100 CHAR),
  secondresourcecollection VARCHAR2(255 CHAR),
  secondresourceid VARCHAR2(56 CHAR),
  secondpropertyname VARCHAR2(100 CHAR)
);


PROMPT Creating Primary Key Constraint pk_relationships on table relationships ...
ALTER TABLE relationships
ADD CONSTRAINT pk_relationships PRIMARY KEY
(
  id
)
ENABLE
;

PROMPT Creating Indexes on relationships ...
CREATE INDEX idx_relationships_first_obj ON relationships
(
  firstresourcecollection,
  firstresourceid,
  firstpropertyname
)
;

CREATE INDEX idx_relationships_second_obj ON relationships
(
  secondresourcecollection,
  secondresourceid,
  secondpropertyname
)
;

CREATE UNIQUE INDEX idx_relationships_object ON relationships
(
  objectid
)
;

CREATE INDEX idx_relationships_originFirst ON relationships
(
  firstresourceid,
  firstresourcecollection,
  firstpropertyname,
  secondresourceid,
  secondresourcecollection
);

CREATE INDEX idx_relationships_originSecond ON relationships
(
  secondresourceid,
  secondresourcecollection,
  secondpropertyname,
  firstresourceid,
  firstresourcecollection
);



-- DROP TABLE relationshipproperties CASCADE CONSTRAINTS;


PROMPT Creating Table relationshipproperties ...
CREATE TABLE relationshipproperties (
  relationships_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(255 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);

PROMPT Creating Primary Key Constraint PRIMARY_21 on table relationshipproperties ...
ALTER TABLE relationshipproperties
ADD CONSTRAINT PRIMARY_21 PRIMARY KEY
(
  relationships_id,
  propkey,
  propindex
)
;

PROMPT Creating Foreign Key Constraint fk_relationshipproperties_conf on table relationshipproperties...
ALTER TABLE relationshipproperties
ADD CONSTRAINT fk_relationshipproperties_conf FOREIGN KEY
(
  relationships_id
)
REFERENCES relationships
(
  id
)
ON DELETE CASCADE
ENABLE
;
PROMPT Creating Index fk_relationshipproperties_conf on relationshipproperties ...
CREATE INDEX fk_relationshipproperties_conf ON relationshipproperties
(
  relationships_id
)
;
PROMPT Creating Index idx_relationshippropert_1 on relationshipproperties ...
CREATE INDEX idx_relationshippropert_1 ON relationshipproperties
(
  propkey
)
;
PROMPT Creating Index idx_relationshippropert_2 on relationshipproperties ...
CREATE INDEX idx_relationshippropert_2 ON relationshipproperties
(
  propvalue
)
;

-- DROP TABLE genericobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table genericobjectproperties ...
CREATE TABLE genericobjectproperties (
  genericobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(32 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_genericobjectproperties_gen on genericobjectproperties ...
CREATE INDEX fk_genericobjectproperties_gen ON genericobjectproperties
(
  genericobjects_id
)
;
PROMPT Creating Index idx_genericobjectproper_1 on genericobjectproperties ...
CREATE INDEX idx_genericobjectproper_1 ON genericobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_genericobjectproper_2 on genericobjectproperties ...
CREATE INDEX idx_genericobjectproper_2 ON genericobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_16 on table genericobjectproperties ...
ALTER TABLE genericobjectproperties
ADD CONSTRAINT PRIMARY_16 PRIMARY KEY
(
  genericobjects_id,
  propkey,
  propindex
)
;


-- DROP TABLE genericobjects CASCADE CONSTRAINTS;


PROMPT Creating Table genericobjects ...
CREATE TABLE genericobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_5 on table genericobjects ...
ALTER TABLE genericobjects
ADD CONSTRAINT PRIMARY_5 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_genericobjects_object on genericobjects...
CREATE UNIQUE INDEX idx_genericobjects_object ON genericobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_genericobjects_objecttypes on genericobjects ...
CREATE INDEX fk_genericobjects_objecttypes ON genericobjects
(
  objecttypes_id
)
;


-- DROP TABLE internaluser CASCADE CONSTRAINTS;


PROMPT Creating Table internaluser ...
CREATE TABLE internaluser (
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  pwd VARCHAR2(510 CHAR)
);


PROMPT Creating Primary Key Constraint PRIMARY_2 on table internaluser ...
ALTER TABLE internaluser
ADD CONSTRAINT PRIMARY_2 PRIMARY KEY
(
  objectid
)
ENABLE
;


-- DROP TABLE internalrole CASCADE CONSTRAINTS;

PROMPT Creating Table internalrole ...
CREATE TABLE internalrole (
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  name VARCHAR2(64 CHAR),
  description VARCHAR2(510 CHAR),
  temporalConstraints VARCHAR2(1024 CHAR),
  condition VARCHAR2(1024 CHAR),
  privs CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_8 on table internalrole ...
ALTER TABLE internalrole
ADD CONSTRAINT PRIMARY_8 PRIMARY KEY
(
  objectid
)
ENABLE
;

-- DROP TABLE links CASCADE CONSTRAINTS;


PROMPT Creating Table links ...
CREATE TABLE links (
  objectid VARCHAR2(38 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  linktype VARCHAR2(255 CHAR) NOT NULL,
  linkqualifier VARCHAR2(50 CHAR) NOT NULL,
  firstid VARCHAR2(255 CHAR) NOT NULL,
  secondid VARCHAR2(255 CHAR) NOT NULL
);


PROMPT Creating Primary Key Constraint PRIMARY_4 on table links ...
ALTER TABLE links
ADD CONSTRAINT PRIMARY_4 PRIMARY KEY
(
  objectid
)
ENABLE
;
PROMPT Creating Index idx_links_first on links ...
CREATE UNIQUE INDEX idx_links_first ON links
(
  linktype,
  linkqualifier,
  firstid
)
;
PROMPT Creating Index idx_links_second on links ...
CREATE UNIQUE INDEX idx_links_second ON links
(
  linktype,
  linkqualifier,
  secondid
)
;
PROMPT Creating Index idx_links_firstid on links ...
CREATE INDEX idx_links_firstid ON links
(
  firstid
)
;
PROMPT Creating Index idx_links_secondid on links ...
CREATE INDEX idx_links_secondid ON links
(
  secondid
)
;

-- DROP TABLE managedobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table managedobjectproperties ...
CREATE TABLE managedobjectproperties (
  managedobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(32 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_managedobjectproperties_man on managedobjectproperties ...
CREATE INDEX fk_managedobjectproperties_man ON managedobjectproperties
(
  managedobjects_id
)
;
PROMPT Creating Index idx_managedobjectproper_1 on managedobjectproperties ...
CREATE INDEX idx_managedobjectproper_1 ON managedobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_managedobjectproper_2 on managedobjectproperties ...
CREATE INDEX idx_managedobjectproper_2 ON managedobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_17 on table managedobjectproperties ...
ALTER TABLE managedobjectproperties
ADD CONSTRAINT PRIMARY_17 PRIMARY KEY
(
  managedobjects_id,
  propkey,
  propindex
)
;


-- DROP TABLE managedobjects CASCADE CONSTRAINTS;


PROMPT Creating Table managedobjects ...
CREATE TABLE managedobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_6 on table managedobjects ...
ALTER TABLE managedobjects
ADD CONSTRAINT PRIMARY_6 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_managedobjects_object on managedobjects...
CREATE UNIQUE INDEX idx_managedobjects_object ON managedobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_managedobjects_objectypes on managedobjects ...
CREATE INDEX fk_managedobjects_objectypes ON managedobjects
(
  objecttypes_id
)
;

-- DROP TABLE schedobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table schedobjectproperties ...
CREATE TABLE schedobjectproperties (
  schedulerobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(32 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_schedobjectproperties_man on schedobjectproperties ...
CREATE INDEX fk_schedobjectproperties_man ON schedobjectproperties
(
  schedulerobjects_id
)
;
PROMPT Creating Index idx_schedobjectproperties_1 on schedobjectproperties ...
CREATE INDEX idx_schedobjectproperties_1 ON schedobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_schedobjectproperties_2 on schedobjectproperties ...
CREATE INDEX idx_schedobjectproperties_2 ON schedobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_18 on table schedobjectproperties ...
ALTER TABLE schedobjectproperties
ADD CONSTRAINT PRIMARY_18 PRIMARY KEY
(
  schedulerobjects_id,
  propkey,
  propindex
)
;


-- DROP TABLE schedulerobjects CASCADE CONSTRAINTS;


PROMPT Creating Table schedulerobjects ...
CREATE TABLE schedulerobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_9 on table schedulerobjects ...
ALTER TABLE schedulerobjects
ADD CONSTRAINT PRIMARY_9 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_schedulerobjects_object on schedulerobjects...
CREATE UNIQUE INDEX idx_schedulerobjects_object ON schedulerobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_schedulerobjects_objectypes on schedulerobjects ...
CREATE INDEX fk_schedulerobjects_objectypes ON schedulerobjects
(
  objecttypes_id
)
;

-- DROP TABLE clusterobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table clusterobjectproperties ...
CREATE TABLE clusterobjectproperties (
  clusterobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(32 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_clusterobjectproperties_man on clusterobjectproperties ...
CREATE INDEX fk_clusterobjectproperties_man ON clusterobjectproperties
(
  clusterobjects_id
)
;
PROMPT Creating Index idx_clusterobjectproperties_1 on clusterobjectproperties ...
CREATE INDEX idx_clusterobjectproperties_1 ON clusterobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_clusterobjectproperties_2 on clusterobjectproperties ...
CREATE INDEX idx_clusterobjectproperties_2 ON clusterobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_19 on table clusterobjectproperties ...
ALTER TABLE clusterobjectproperties
ADD CONSTRAINT PRIMARY_19 PRIMARY KEY
(
  clusterobjects_id,
  propkey,
  propindex
)
;


-- DROP TABLE clusterobjects CASCADE CONSTRAINTS;


PROMPT Creating Table clusterobjects ...
CREATE TABLE clusterobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_10 on table clusterobjects ...
ALTER TABLE clusterobjects
ADD CONSTRAINT PRIMARY_10 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_clusterobjects_object on clusterobjects...
CREATE UNIQUE INDEX idx_clusterobjects_object ON clusterobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_clusterobjects_objectypes on clusterobjects ...
CREATE INDEX fk_clusterobjects_objectypes ON clusterobjects
(
  objecttypes_id
)
;


-- DROP TABLE clusteredrecontargetids CASCADE CONSTRAINTS;


PROMPT Creating Table clusteredrecontargetids ...
CREATE TABLE clusteredrecontargetids (
  objectid VARCHAR2(38 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  reconid VARCHAR2(255 CHAR) NOT NULL,
  targetids CLOB NOT NULL
);
PROMPT Creating Primary Key Constraint PRIMARY_11 on table clusteredrecontargetids ...
ALTER TABLE clusteredrecontargetids
ADD CONSTRAINT PRIMARY_11 PRIMARY KEY
(
  objectid
)
ENABLE
;

PROMPT Creating Index idx_clusteredrecontids_rid on clusteredrecontargetids...
CREATE INDEX idx_clusteredrecontids_rid ON clusteredrecontargetids
(
  reconid
)
;



-- DROP TABLE updateobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table updateobjectproperties ...
CREATE TABLE updateobjectproperties (
  updateobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(32 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_updateobjectproperties_gen on updateobjectproperties ...
CREATE INDEX fk_updateobjectproperties_gen ON updateobjectproperties
(
  updateobjects_id
)
;
PROMPT Creating Index idx_updateobjectproper_1 on updateobjectproperties ...
CREATE INDEX idx_updateobjectproper_1 ON updateobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_updateobjectproper_2 on updateobjectproperties ...
CREATE INDEX idx_updateobjectproper_2 ON updateobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_20 on table updateobjectproperties ...
ALTER TABLE updateobjectproperties
ADD CONSTRAINT PRIMARY_20 PRIMARY KEY
(
  updateobjects_id,
  propkey,
  propindex
)
;


-- DROP TABLE updateobjects CASCADE CONSTRAINTS;


PROMPT Creating Table updateobjects ...
CREATE TABLE updateobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_14 on table updateobjects ...
ALTER TABLE updateobjects
ADD CONSTRAINT PRIMARY_14 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_updateobjects_object on updateobjects...
CREATE UNIQUE INDEX idx_updateobjects_object ON updateobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_updateobjects_objecttypes on updateobjects ...
CREATE INDEX fk_updateobjects_objecttypes ON updateobjects
(
  objecttypes_id
)
;

-- DROP TABLE importobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table importobjectproperties ...
CREATE TABLE importobjectproperties (
  importobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(32 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_importobjectproperties_gen on importobjectproperties ...
CREATE INDEX fk_importobjectproperties_gen ON importobjectproperties
(
  importobjects_id
)
;
PROMPT Creating Index idx_importobjectproper_1 on importobjectproperties ...
CREATE INDEX idx_importobjectproper_1 ON importobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_importobjectproper_2 on importobjectproperties ...
CREATE INDEX idx_importobjectproper_2 ON importobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_33 on table importobjectproperties ...
ALTER TABLE importobjectproperties
ADD CONSTRAINT PRIMARY_33 PRIMARY KEY
(
  importobjects_id,
  propkey,
  propindex
)
;


-- DROP TABLE importobjects CASCADE CONSTRAINTS;


PROMPT Creating Table importobjects ...
CREATE TABLE importobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_34 on table importobjects ...
ALTER TABLE importobjects
ADD CONSTRAINT PRIMARY_34 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_importobjects_object on importobjects...
CREATE UNIQUE INDEX idx_importobjects_object ON importobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_importobjects_objecttypes on importobjects ...
CREATE INDEX fk_importobjects_objecttypes ON importobjects
(
  objecttypes_id
)
;

-- DROP TABLE objecttypes CASCADE CONSTRAINTS;

PROMPT Creating Table objecttypes ...
CREATE TABLE objecttypes (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttype VARCHAR2(255 CHAR) NOT NULL
);

PROMPT Creating Primary Key Constraint primary_objecttypes_id on table objecttypes ...
ALTER TABLE objecttypes
ADD CONSTRAINT primary_objecttypes_id PRIMARY KEY
(
  id
)
ENABLE
;

PROMPT Creating Unique Index idx_objecttypes_objecttype on objecttypes...
CREATE UNIQUE INDEX idx_objecttypes_objecttype ON objecttypes
(
  objecttype
)
;


-- DROP TABLE syncqueue CASCADE CONSTRAINTS;

PROMPT Creating Table syncqueue ...
CREATE TABLE syncqueue (
  objectid           VARCHAR2(38 CHAR)  NOT NULL,
  rev                VARCHAR2(38 CHAR)  NOT NULL,
  syncAction         VARCHAR2(38 CHAR)  NOT NULL,
  resourceCollection VARCHAR2(38 CHAR)  NOT NULL,
  resourceId         VARCHAR2(255 CHAR) NOT NULL,
  mapping            VARCHAR2(255 CHAR) NOT NULL,
  objectRev          VARCHAR2(38 CHAR)  NULL,
  oldObject          CLOB          NULL,
  newObject          CLOB          NULL,
  context            CLOB          NOT NULL,
  state              VARCHAR2(38 CHAR)  NOT NULL,
  nodeId             VARCHAR2(255 CHAR) NULL,
  createDate         VARCHAR2(255 CHAR) NOT NULL
);
PROMPT Creating Primary Key Constraint PRIMARY_22 on table syncqueue ..
ALTER TABLE syncqueue
  ADD CONSTRAINT PRIMARY_22 PRIMARY KEY
  (
    objectid
  )
ENABLE
;
PROMPT Creating Index idx_syncqueue_map_state_crdt on syncqueue...
CREATE INDEX idx_syncqueue_map_state_crdt ON syncqueue
(
  mapping,
  state,
  createDate
)
;

-- DROP TABLE locks CASCADE CONSTRAINTS;


PROMPT Creating Table locks ...
CREATE TABLE locks (
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  nodeid VARCHAR2(255 CHAR)
);
PROMPT Creating Primary Key Constraint PRIMARY_26 on table locks ...
ALTER TABLE locks
ADD CONSTRAINT PRIMARY_26 PRIMARY KEY
(
  objectid
)
ENABLE
;

PROMPT Creating Index idx_locks_nid on locks...
CREATE INDEX idx_locks_nid ON locks
(
  nodeid
)
;

-- DROP TABLE files CASCADE CONSTRAINTS;


PROMPT Creating Table files ...
CREATE TABLE files (
  objectid VARCHAR2(38 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  content CLOB NULL
);
PROMPT Creating Primary Key Constraint PRIMARY_27 on table files ...
ALTER TABLE files
ADD CONSTRAINT PRIMARY_27 PRIMARY KEY
(
  objectid
)
ENABLE
;

-- DROP TABLE reconassoc CASCADE CONSTRAINTS;

PROMPT Creating Table reconassoc ...
CREATE TABLE reconassoc
(
    objectid VARCHAR2(255) NOT NULL,
    rev VARCHAR2(38) NOT NULL,
    mapping VARCHAR2(255) NOT NULL,
    sourceResourceCollection VARCHAR2(255) NOT NULL,
    targetResourceCollection VARCHAR2(255) NOT NULL,
    isAnalysis VARCHAR2(5) NOT NULL,
    finishTime VARCHAR2(38) NULL
);
PROMPT Creating Primary Key Contraint PRIMARY_31 on table reconassoc ...
ALTER TABLE reconassoc
  ADD CONSTRAINT PRIMARY_31 PRIMARY KEY
    (
     objectid
    )
    ENABLE
;
PROMPT Creating Index idx_reconassoc_mapping on reconassoc...
CREATE INDEX idx_reconassoc_mapping ON reconassoc
  (
   mapping
  )
;

-- DROP TABLE reconassocentry CASCADE CONSTRAINTS;

PROMPT Creating Table reconassocentry ...
CREATE TABLE reconassocentry
(
     objectid VARCHAR2(38) NOT NULL,
     rev VARCHAR2(38) NOT NULL,
     reconId VARCHAR2(255) NOT NULL,
     situation VARCHAR2(38) NULL,
     action VARCHAR2(38) NULL,
     phase VARCHAR2(38) NULL,
     linkQualifier VARCHAR2(38) NOT NULL,
     sourceObjectId VARCHAR2(255) NULL,
     targetObjectId VARCHAR2(255) NULL,
     status VARCHAR2(38) NOT NULL,
     exception CLOB NULL,
     message CLOB NULL,
     messagedetail CLOB NULL,
     ambiguousTargetObjectIds CLOB NULL
);
PROMPT Creating Primary Key Contraint PRIMARY_32 on table reconassocentry ...
ALTER TABLE reconassocentry
  ADD CONSTRAINT PRIMARY_32 PRIMARY KEY
    (
     objectid
    )
  ENABLE
;
ALTER TABLE reconassocentry
  ADD CONSTRAINT fk_rnasscntry_rnassc_id FOREIGN KEY
    (
     reconId
    )
    REFERENCES reconassoc
      (
       objectid
      )
    ON DELETE CASCADE
    ENABLE
;

PROMPT Creating Index idx_reconassocentry_situation on reconassocentry...
CREATE INDEX idx_reconassocentry_situation ON reconassocentry
  (
   situation
  )
;

-- -----------------------------------------------------
-- View openidm.reconassocentryview
-- -----------------------------------------------------

CREATE VIEW reconassocentryview AS
  SELECT
    assoc.objectid as reconId,
    assoc.mapping as mapping,
    assoc.sourceResourceCollection as sourceResourceCollection,
    assoc.targetResourceCollection as targetResourceCollection,
    entry.objectid AS objectid,
    entry.rev AS rev,
    entry.action AS action,
    entry.situation AS situation,
    entry.linkQualifier as linkQualifier,
    entry.sourceObjectId as sourceObjectId,
    entry.targetObjectId as targetObjectId,
    entry.status as status,
    entry.exception as exception,
    entry.message as message,
    entry.messagedetail as messagedetail,
    entry.ambiguousTargetObjectIds as ambiguousTargetObjectIds
  FROM reconassocentry entry, reconassoc assoc
  WHERE assoc.objectid = entry.reconid
;

-- DROP TABLE metaobjectproperties CASCADE CONSTRAINTS;


PROMPT Creating Table metaobjectproperties ...
CREATE TABLE metaobjectproperties (
  metaobjects_id NUMBER(24,0) NOT NULL,
  propkey VARCHAR2(255 CHAR) NOT NULL,
  proptype VARCHAR2(32 CHAR),
  propvalue VARCHAR2(2000 CHAR),
  propindex NUMBER(24,0) DEFAULT 0 NOT NULL
);


PROMPT Creating Index fk_metaobjectproperties_gen on metaobjectproperties ...
CREATE INDEX fk_metaobjectproperties_gen ON metaobjectproperties
(
  metaobjects_id
)
;
PROMPT Creating Index idx_metaobjectproper_1 on metaobjectproperties ...
CREATE INDEX idx_metaobjectproper_1 ON metaobjectproperties
(
  propkey
)
;
PROMPT Creating Index idx_metaobjectproper_2 on metaobjectproperties ...
CREATE INDEX idx_metaobjectproper_2 ON metaobjectproperties
(
  propvalue
)
;

PROMPT Creating Primary Key Constraint PRIMARY_28 on table metaobjectproperties ...
ALTER TABLE metaobjectproperties
ADD CONSTRAINT PRIMARY_28 PRIMARY KEY
(
  metaobjects_id,
  propkey,
  propindex
)
;


-- DROP TABLE metaobjects CASCADE CONSTRAINTS;


PROMPT Creating Table metaobjects ...
CREATE TABLE metaobjects (
  id NUMBER(24,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
  objecttypes_id NUMBER(24,0) NOT NULL,
  objectid VARCHAR2(255 CHAR) NOT NULL,
  rev VARCHAR2(38 CHAR) NOT NULL,
  fullobject CLOB
);


PROMPT Creating Primary Key Constraint PRIMARY_29 on table metaobjects ...
ALTER TABLE metaobjects
ADD CONSTRAINT PRIMARY_29 PRIMARY KEY
(
  id
)
ENABLE
;
PROMPT Creating Unique Index idx_metaobjects_object on metaobjects...
CREATE UNIQUE INDEX idx_metaobjects_object ON metaobjects
(
  objecttypes_id,
  objectid
)
;
PROMPT Creating Index fk_metaobjects_objecttypes on metaobjects ...
CREATE INDEX fk_metaobjects_objecttypes ON metaobjects
(
  objecttypes_id
)
;


PROMPT Creating Foreign Key Constraint fk_configobjectproperties_conf on table configobjects...
ALTER TABLE configobjectproperties
ADD CONSTRAINT fk_configobjectproperties_conf FOREIGN KEY
(
  configobjects_id
)
REFERENCES configobjects
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_configobjects_objecttypes on table objecttypes...
ALTER TABLE configobjects
ADD CONSTRAINT fk_configobjects_objecttypes FOREIGN KEY
(
  objecttypes_id
)
REFERENCES objecttypes
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_notificationproperties_conf on table notificationobjects...
ALTER TABLE notificationobjectproperties
ADD CONSTRAINT fk_notificationproperties_conf FOREIGN KEY
(
  notificationobjects_id
)
REFERENCES notificationobjects
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_notification_objecttypes on table objecttypes...
ALTER TABLE notificationobjects
ADD CONSTRAINT fk_notification_objecttypes FOREIGN KEY
(
  objecttypes_id
)
REFERENCES objecttypes
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_genericobjects_objecttypes on table objecttypes...
ALTER TABLE genericobjects
ADD CONSTRAINT fk_genericobjects_objecttypes FOREIGN KEY
(
  objecttypes_id
)
REFERENCES objecttypes
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_managedobjectproperties_man on table managedobjects...
ALTER TABLE managedobjectproperties
ADD CONSTRAINT fk_managedobjectproperties_man FOREIGN KEY
(
  managedobjects_id
)
REFERENCES managedobjects
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_managedobjects_objectypes on table objecttypes...
ALTER TABLE managedobjects
ADD CONSTRAINT fk_managedobjects_objectypes FOREIGN KEY
(
  objecttypes_id
)
REFERENCES objecttypes
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_schedobjectproperties_man on table schedobjectproperties...
ALTER TABLE schedobjectproperties
  ADD CONSTRAINT fk_schedobjectproperties_man FOREIGN KEY
  (
    schedulerobjects_id
  )
REFERENCES schedulerobjects
  (
    id
  )
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_schedulerobjects_objectypes on table schedulerobjects...
ALTER TABLE schedulerobjects
  ADD CONSTRAINT fk_schedulerobjects_objectypes FOREIGN KEY
  (
    objecttypes_id
  )
REFERENCES objecttypes
  (
    id
  )
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_clusterobjectproperties_man on table clusterobjectproperties...
ALTER TABLE clusterobjectproperties
  ADD CONSTRAINT fk_clusterobjectproperties_man FOREIGN KEY
  (
    clusterobjects_id
  )
REFERENCES clusterobjects
  (
    id
  )
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_clusterobjects_objectypes on table clusterobjects...
ALTER TABLE clusterobjects
  ADD CONSTRAINT fk_clusterobjects_objectypes FOREIGN KEY
  (
    objecttypes_id
  )
REFERENCES objecttypes
  (
    id
  )
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_relationships_objecttypes on table relationships...
ALTER TABLE relationships
  ADD CONSTRAINT fk_relationships_objecttypes FOREIGN KEY
  (
    objecttypes_id
  )
REFERENCES objecttypes
  (
    id
  )
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_genericobjectproperties_gen on table genericobjects...
ALTER TABLE genericobjectproperties
ADD CONSTRAINT fk_genericobjectproperties_gen FOREIGN KEY
(
  genericobjects_id
)
REFERENCES genericobjects
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_updateobjectproperties_man on table updateobjectproperties...
ALTER TABLE updateobjectproperties
ADD CONSTRAINT fk_updateobjectproperties_man FOREIGN KEY
(
  updateobjects_id
)
REFERENCES updateobjects
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_updateobjects_objectypes on table updateobjects...
ALTER TABLE updateobjects
ADD CONSTRAINT fk_updateobjects_objectypes FOREIGN KEY
(
  objecttypes_id
)
REFERENCES objecttypes
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_metaproperties_conf on table metaobjects...
ALTER TABLE metaobjectproperties
ADD CONSTRAINT fk_metaproperties_conf FOREIGN KEY
(
  metaobjects_id
)
REFERENCES metaobjects
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_meta_objecttypes on table objecttypes...
ALTER TABLE metaobjects
ADD CONSTRAINT fk_meta_objecttypes FOREIGN KEY
(
  objecttypes_id
)
REFERENCES objecttypes
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_importproperties_conf on table importobjects...
ALTER TABLE importobjectproperties
ADD CONSTRAINT fk_importproperties_conf FOREIGN KEY
(
  importobjects_id
)
REFERENCES importobjects
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Foreign Key Constraint fk_import_objecttypes on table objecttypes...
ALTER TABLE importobjects
ADD CONSTRAINT fk_import_objecttypes FOREIGN KEY
(
  objecttypes_id
)
REFERENCES objecttypes
(
  id
)
ON DELETE CASCADE
ENABLE
;

PROMPT Creating Table relationshipresources...
CREATE TABLE relationshipresources (
     id VARCHAR2(255 CHAR) NOT NULL,
     originresourcecollection VARCHAR(255) NOT NULL,
     originproperty VARCHAR(100) NOT NULL,
     refresourcecollection VARCHAR(255) NOT NULL,
     originfirst NUMBER NOT NULL,
     reverseproperty VARCHAR(100)
);

PROMPT Creating PK pk_relationshipresources on relationshipresources...
ALTER TABLE relationshipresources
ADD CONSTRAINT pk_relationshipresources PRIMARY KEY
(
  originresourcecollection, originproperty, refresourcecollection, originfirst
)
ENABLE
;

/
