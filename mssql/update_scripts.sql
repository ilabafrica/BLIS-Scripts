if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BlissLabResults]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[BlissLabResults];

CREATE TABLE [dbo].[BlissLabResults] (
	[ID] [bigint] IDENTITY (1, 1) NOT NULL ,
	[RequestID] [bigint] NOT NULL ,
	[OfferedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[DateOffered] [datetime] NOT NULL ,
	[TimeOffered] [datetime] NOT NULL ,
	[TestResults] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];
;






if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OPDRevisitsForBlissQuery]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.OPDRevisitsForBlissQuery;

SET QUOTED_IDENTIFIER ON ;
SET ANSI_NULLS ON ;


CREATE VIEW dbo.OPDRevisitsForBlissQuery
AS
SELECT     PatientNumber, DateOfVisit AS DateOfRegistration, RevisitNumber
FROM         dbo.OutPatientRevisits
WHERE     (RevisitNumber = 0);
SET QUOTED_IDENTIFIER OFF ;
SET ANSI_NULLS ON ;

SET QUOTED_IDENTIFIER ON ;
SET ANSI_NULLS ON ;








if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Outpatientss]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.Outpatientss;

SET QUOTED_IDENTIFIER ON ;
SET ANSI_NULLS ON ;



CREATE VIEW dbo.Outpatientss
AS
SELECT     dbo.OutPatients.ID, dbo.OutPatients.PatientNumber, dbo.OutPatients.FullNames, dbo.OutPatients.Sex, dbo.OutPatients.Age, 
                      dbo.OutPatients.PatientsContact, dbo.OutPatients.NHIFNumber, dbo.OutPatients.PayerOfBill, dbo.OutPatients.PoBox, dbo.OutPatients.Telephone, 
                      dbo.OutPatients.ClientStatus, dbo.OutPatients.StaffNo, dbo.OutPatients.Allergy, dbo.OPDRevisitsForBlissQuery.DateOfRegistration
FROM         dbo.OPDRevisitsForBlissQuery RIGHT OUTER JOIN
                      dbo.OutPatients ON dbo.OPDRevisitsForBlissQuery.PatientNumber = dbo.OutPatients.PatientNumber

;
SET QUOTED_IDENTIFIER OFF 
;
SET ANSI_NULLS ON 
;

SET QUOTED_IDENTIFIER ON 
;
SET ANSI_NULLS ON 
;









if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AllPatientsQuery]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.AllPatientsQuery
;

SET QUOTED_IDENTIFIER ON 
;
SET ANSI_NULLS ON 
;


CREATE VIEW dbo.AllPatientsQuery
AS
SELECT     ISNULL(dbo.Outpatientss.ID, dbo.Patients.ID) AS ID, ISNULL(dbo.Patients.PatientNumber, dbo.Outpatientss.PatientNumber) AS PatientNumber, 
                      ISNULL(dbo.Outpatientss.FullNames, dbo.Patients.Name) AS FullNames, ISNULL(dbo.Outpatientss.Age, dbo.Patients.Age) AS Age, 
                      ISNULL(dbo.Outpatientss.NHIFNumber, dbo.Patients.NHIFNumber) AS NHIFNumber, ISNULL(dbo.Outpatientss.PayerOfBill, dbo.Patients.PayerOfBill) 
                      AS PayerOfBill, ISNULL(dbo.Outpatientss.PatientsContact, dbo.Patients.PatientsContact) AS PatientsContact, ISNULL(dbo.Outpatientss.Sex, 
                      dbo.Patients.Sex) AS Sex, ISNULL(dbo.Outpatientss.PoBox, dbo.Patients.PoBox) AS PoBox, dbo.Outpatientss.ClientStatus, 
                      ISNULL(dbo.Outpatientss.Telephone, dbo.Patients.Telephone) AS Telephone, dbo.Outpatientss.StaffNo, dbo.Patients.Bed, 
                      ISNULL(dbo.Outpatientss.DateOfRegistration, dbo.Patients.DateOfRegistration) AS DateOfRegistration
FROM         dbo.Outpatientss FULL OUTER JOIN
                      dbo.Patients ON dbo.Outpatientss.PatientNumber = dbo.Patients.PatientNumber

;
SET QUOTED_IDENTIFIER OFF 
;
SET ANSI_NULLS ON 
;

SET QUOTED_IDENTIFIER ON 
;
SET ANSI_NULLS ON 
;









if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServicesRequestsQuery]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.ServicesRequestsQuery
;

SET QUOTED_IDENTIFIER ON 
;
SET ANSI_NULLS ON 
;


CREATE VIEW dbo.ServicesRequestsQuery
AS
SELECT     dbo.RequestForms.ID AS RequestID, dbo.RequestForms.PatientNumber, dbo.RequestForms.RevisitNumber, dbo.RequestForms.DateOfRequest, 
                      dbo.RequestForms.Service, dbo.Services.Name, dbo.RequestForms.X, dbo.RequestForms.Cost, dbo.RequestForms.UnitsConsumed, 
                      dbo.RequestForms.DoctorRequesting, dbo.BlissLabResults.OfferedBy, dbo.RequestForms.TimeOfRequest, dbo.RequestForms.WaiverNo, 
                      dbo.RequestForms.WaiverAmount, dbo.RequestForms.ReceiptNumber, dbo.Departments.Name AS Department, dbo.Services.CashItem, 
                      dbo.Services.ProcedureItem, dbo.BlissLabResults.TestResults AS Results, dbo.RequestForms.Comments, dbo.BlissLabResults.DateOffered, 
                      dbo.BlissLabResults.TimeOffered, dbo.Services.IsTreatment, ISNULL(dbo.CorporateClients.Name, N'SELF') AS PayerOfBill, 
                      dbo.RequestForms.ProvisionalDiagnosis, dbo.RequestForms.ShowInRequestGrid, dbo.RequestForms.CreditAmount, 
                      dbo.RequestForms.ExemptedAmount, dbo.AllPatientsQuery.Sex, dbo.AllPatientsQuery.Age
FROM         dbo.BlissLabResults RIGHT OUTER JOIN
                      dbo.Services INNER JOIN
                      dbo.RequestForms ON dbo.Services.ID = dbo.RequestForms.Service INNER JOIN
                      dbo.Departments ON dbo.Services.Department = dbo.Departments.ID ON dbo.BlissLabResults.RequestID = dbo.RequestForms.ID RIGHT OUTER JOIN
                      dbo.AllPatientsQuery LEFT OUTER JOIN
                      dbo.CorporateClients ON dbo.AllPatientsQuery.PayerOfBill = dbo.CorporateClients.ID ON 
                      dbo.RequestForms.PatientNumber = dbo.AllPatientsQuery.PatientNumber

;
SET QUOTED_IDENTIFIER OFF 
;
SET ANSI_NULLS ON 
;

SET QUOTED_IDENTIFIER ON 
;
SET ANSI_NULLS ON 
;













if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LabRequestQueryForBliss]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view dbo.LabRequestQueryForBliss
;

SET QUOTED_IDENTIFIER ON 
;
SET ANSI_NULLS ON 
;



CREATE VIEW dbo.LabRequestQueryForBliss
AS
SELECT     dbo.RequestForms.ID AS RequestID, dbo.RequestForms.PatientNumber, dbo.AllPatientsQuery.FullNames, dbo.AllPatientsQuery.Sex, 
                      dbo.AllPatientsQuery.Age, dbo.RequestForms.RevisitNumber, dbo.AllPatientsQuery.PoBox, dbo.AllPatientsQuery.PatientsContact, 
                      dbo.AllPatientsQuery.Telephone, dbo.RequestForms.DateOfRequest, dbo.RequestForms.TimeOfRequest, dbo.Services.Name, dbo.RequestForms.Cost, 
                      dbo.PassWords.FirstName + ' ' + dbo.PassWords.LastName AS DoctorRequesting, dbo.RequestForms.ReceiptNumber, dbo.RequestForms.WaiverNo, 
                      dbo.RequestForms.Comments, dbo.RequestForms.ProvisionalDiagnosis, dbo.AllPatientsQuery.DateOfRegistration
FROM         dbo.AllPatientsQuery INNER JOIN
                      dbo.PassWords INNER JOIN
                      dbo.Services INNER JOIN
                      dbo.RequestForms ON dbo.Services.ID = dbo.RequestForms.Service INNER JOIN
                      dbo.Departments ON dbo.Services.Department = dbo.Departments.ID ON dbo.PassWords.UserName = dbo.RequestForms.DoctorRequesting ON 
                      dbo.AllPatientsQuery.PatientNumber = dbo.RequestForms.PatientNumber
WHERE     (dbo.Departments.Name = 'LABORATORY')

;
SET QUOTED_IDENTIFIER OFF 
;
SET ANSI_NULLS ON 
;

SET QUOTED_IDENTIFIER ON 
;
SET ANSI_NULLS ON 
;
