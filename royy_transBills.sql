USE [ProfitAge]
GO
/****** Object:  StoredProcedure [dbo].[royy_TransBills]    Script Date: 03/31/2019 07:35:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[royy_TransBills]
AS

select * into #tmpBills
FROM  tblTransBills
where fldOpenTime > getdate() - 3

select * into #tmpMain
FROM  tblTransMain
where fldTime > getdate() - 3

SELECT  

	convert(varchar(50),tblTransBills.fldBill) + '-' + convert(varchar,tblSession.fldTerminal) as 'BILLNO'
	  ,tblTransSales.[fldLine] as 'LINE'
	  --,convert(varchar(22),tblTransSales.fldCode) as 'PART'
	  ,case when tblTransSales.fldCode = 1 then '71366' else convert(varchar(22),tblTransSales.fldCode) end as 'PART'
	  --  code for generic standard general part in Priority
	  --,case when tblTransSales.fldCode = 1 then '-20' else convert(varchar(22),tblTransSales.fldCode) end as 'PART'
	  ,[fldPrice] / 100.0 as 'Price'
	  ,[fldQty] as 'Qty'
      ,[fldTotal] / 100.0 as 'Total'
	  ,[fldNetTotal]  /100.0 as 'NetTotal' -- after line discount and general discount 
	  ,[fldVAT] as 'VAT'
	  ,[fldVATRate] as 'VATRate'
	  ,coalesce(tblTransAddedInputs.fldFieldValue,'') as 'Value'
	  ,fldOpenTime
	  
	  FROM  tblTransSales 
	  inner join  #tmpBills tblTransBills  on tblTransBills.fldSequence = tblTransSales.fldSequence		
    	inner join #tmpMain tblTransMain  on tblTransMain.fldSequence = tblTransBills.fldSequence
		inner join  tblSession  on tblSession.fldSessionID = tblTransMain.fldSessionID 
		left join   tblTransAddedInputs  on tblTransAddedInputs.fldStore = tblTransSales.fldStore and tblTransAddedInputs.fldSequence = tblTransSales.fldSequence and tblTransSales.fldLine = tblTransAddedInputs.fldLine
		where tblTransBills.fldCloseMode in (0, 2)

drop table #tmpBills
drop table #tmpMain





