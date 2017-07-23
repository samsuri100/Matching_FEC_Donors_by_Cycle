/*
Copyright 2017 Sam Suri, all rights reserved. Only use with permission. Contact: samsuri100@gmail.com, (210)296-6021
*/

--Declaring temporary tables to store result of future common table expressions
DECLARE @2016 Table(
	[Candidate ID] varchar(255),[Amendment Indicator] varchar(255),[Report Type] varchar(255),
	[Primary-General Indicator] varchar(255),[Image Number] varchar(255),[Transaction Type] varchar(255),
	[Entity Type] varchar(255),[Contributor] varchar(255),[City] varchar(255),[State] varchar(255),
	[Zip Code] varchar(255),[Employer] varchar(255),[Occupation] varchar(255),[Date] varchar(255),[Amount] int,
	[Other ID Info] varchar(255),[Transaction ID] varchar(255),[File Number] varchar(255),[Memo Code] varchar(255),
	[Memo Text] varchar(255),[Fec Record Number] varchar(255),[Year] varchar(255)
);
DECLARE @2014 Table(
	[Candidate ID] varchar(255),[Amendment Indicator] varchar(255),[Report Type] varchar(255),
	[Primary-General Indicator] varchar(255),[Image Number] varchar(255),[Transaction Type] varchar(255),
	[Entity Type] varchar(255),[Contributor] varchar(255),[City] varchar(255),[State] varchar(255),
	[Zip Code] varchar(255),[Employer] varchar(255),[Occupation] varchar(255),[Date] varchar(255),[Amount] int,
	[Other ID Info] varchar(255),[Transaction ID] varchar(255),[File Number] varchar(255),[Memo Code] varchar(255),
	[Memo Text] varchar(255),[Fec Record Number] varchar(255),[Year] varchar(255)
);
DECLARE @2012 Table(
	[Candidate ID] varchar(255),[Amendment Indicator] varchar(255),[Report Type] varchar(255),
	[Primary-General Indicator] varchar(255),[Image Number] varchar(255),[Transaction Type] varchar(255),
	[Entity Type] varchar(255),[Contributor] varchar(255),[City] varchar(255),[State] varchar(255),
	[Zip Code] varchar(255),[Employer] varchar(255),[Occupation] varchar(255),[Date] varchar(255),[Amount] int,
	[Other ID Info] varchar(255),[Transaction ID] varchar(255),[File Number] varchar(255),[Memo Code] varchar(255),
	[Memo Text] varchar(255),[Fec Record Number] varchar(255),[Year] varchar(255)
);

--declaring three different common table expressions, copying results into corresponding tables
--CTE uses derived table to select all columns from original table and then adds a year column, filters results by FEC ID
WITH 2016_CTE AS
( 
select * from (select *,  right([date], 4) as [Year] from [Insert_FEC_DATA]) as D where [Candidate ID] = '[Insert FEC ID]' 
and ([Year] = 2016 or [Year] = 2015) --Only uses 2016 Cycle (2016 and 2015)
)
INSERT INTO @2016 select * from 2016_CTE;


WITH 2014_CTE AS
(
select * from (select *,  right([date], 4) as [Year] from [Insert_FEC_DATA]) as D where [Candidate ID] = '[Insert FEC ID]' 
and ([Year] = 2014 or [Year] = 2013) --Only uses 2014 Cycle (2014 and 2013)
)
INSERT INTO @2014 select * from 2014_CTE;


WITH 2012_CTE AS
(
select * from (select *,  right([date], 4) as [Year] from [Insert_FEC_DATA]) as D where [Candidate ID] = '[Insert FEC ID]' 
and ([Year] = 2012 or [Year] = 2011) --Only uses 2012 Cycle (2012 and 2011)
)
INSERT INTO @2012 select * from 2012_CTE;


/*First Test -- finds donors from 2012 cycle that dropped off in 2014 cycle and 2016 cycle*/
select D.* from (select F.* from @2012 as F left join @2014 as M on F.Contributor = M.Contributor -- uses 2 left joins
and F.[State] = M.[State] and F.City = M.City and F.Employer = M.Employer and
F.Occupation = M.Occupation where M.Contributor is null and M.[State] is null 
and M.City is null and M.Employer is null and M.Occupation is null) as D
Left join @2016 as L on D.Contributor = L.Contributor and D.[State] = L.[State] and 
D.City = L.City and D.Employer = L.Employer and D.Occupation = L.Occupation 
where L.Contributor is null and L.[State] is null and L.City is null and L.Employer is null 
and L.Occupation is null

/*Second Test -- donors from 2014 cycle (who did not donate in 2012 cycle) that dropped off 2016 cycle*/
select D.* from (select M.* from @2012 as F right join @2014 as M on F.Contributor = M.Contributor -- uses right join
and F.[State] = M.[State] and F.City = M.City and F.Employer = M.Employer and
F.Occupation = M.Occupation where F.Contributor is null and F.[State] is null 
and F.City is null and F.Employer is null and F.Occupation is null) as D left join -- uses left join
@2016 as L on D.Contributor = L.Contributor and D.[State] = L.[State] and 
D.City = L.City and D.Employer = L.Employer and D.Occupation = L.Occupation 
where L.Contributor is null and L.[State] is null and L.City is null and L.Employer is null 
and L.Occupation is null

/*Third Test -- new donors from 2016 cycle who have not donated in 2012 cycle or 2014 cycle*/
select D.* from @2014 as M right join (select L.* from @2012 as F right join @2016 as L on F.Contributor = L.Contributor 
and F.[State] = L.[State] and F.City = L.City and F.Employer = L.Employer and -- uses two right joins
F.Occupation = L.Occupation where F.Contributor is null and F.[State] is null 
and F.City is null and F.Employer is null and F.Occupation is null) as D on D.Contributor = M.Contributor and D.[State] = M.[State] and 
D.City = M.City and D.Employer = M.Employer and D.Occupation = M.Occupation 
where M.Contributor is null and M.[State] is null and M.City is null and M.Employer is null 
and M.Occupation is null

/*Fourth Test -- people who have donated in 2012 cycle, 2014 cycle, and 2016 cycle cycle*/
select L.* from (select L1.* from @2016 as L1 inner join @2014 as M on -- uses two inner joins
M.Contributor = L1.Contributor and M.[State] = L1.[State] and M.City = L1.City and 
M.Employer = L1.Employer and M.Occupation = L1.Occupation) as L inner join @2012 as F 
on F.Contributor = L.Contributor and F.[State] = L.[State] and F.City = L.City and F.Employer = L.Employer 
and F.Occupation = L.Occupation