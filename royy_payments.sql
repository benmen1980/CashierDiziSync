USE [ProfitAge]
GO
/****** Object:  StoredProcedure [dbo].[royy_Payments]    Script Date: 03/31/2019 07:35:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[royy_Payments]
	@booknumid varchar(50)
AS
SELECT convert(varchar(50), tblTransBills.fldBill) + '-' + convert(varchar,tblSession.fldTerminal) + @booknumid
			  ,[fldLine]
			  ,fldCode  -- use for credit card to get the type of the credit card company
			  ,coalesce([fldPaymeansGroup], 0)  -- 1 cash, 2 cheque, 7 coupon credit, 4 customer credit, 6 credit card, 9 rounding
			  ,tblTransPayments.fldAmount / 100.0
			  ,right(coalesce([fldNumber],''),16) -- coupon number, cheque
			  ,coalesce([fldBankNumber], '')
			  ,coalesce([fldBranchNumber], '')
			  ,case when coalesce([fldPaymeansGroup], 0) = 6 then right(coalesce([fldNumber],''),4) else left(coalesce([fldAccountNumber], ''),20) end
			  ,left(coalesce([fldIDNumber], ''),10)
			  ,datediff(mi, '01/01/1988', coalesce([fldPayDate], '01/01/1988'))
			  ,coalesce(tblDataCreditCards.fldExpDate, '')
			  ,coalesce(tblDataCreditCards.fldTicketNumber, '')
			  ,coalesce(tblDataCreditCards.fldCreditType, '')
			  ,coalesce(tblDataCreditCards.fldInstallments, 0)
			  ,coalesce(tblDataCreditCards.fldFirstInst / 100.0, 0.0)
			  
		  FROM  tblTransPayments WITH (NOLOCK)
		  inner join tblTransBills WITH (NOLOCK) on tblTransBills.fldSequence = tblTransPayments.fldSequence
					
		  	inner join  tblTransMain WITH (NOLOCK) on tblTransMain.fldSequence = tblTransBills.fldSequence
		inner join  tblSession WITH (NOLOCK) on tblSession.fldSessionID = tblTransMain.fldSessionID
		  left outer join  tblDataCreditCards WITH (NOLOCK) on tblDataCreditCards.fldBill = tblTransBills.fldBill and tblDataCreditCards.fldCardNumber COLLATE DATABASE_DEFAULT = tblTransPayments.fldNumber COLLATE DATABASE_DEFAULT AND tblTransPayments.fldAmount = tblDataCreditCards.fldAmount
		  where tblTransBills.fldCloseMode in (0, 2)
		  and fldCode <> 22 /* עיגול אגורות */
		  and fldOpenTime > GETDATE() -2
