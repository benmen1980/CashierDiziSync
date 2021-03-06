USE [ProfitAge]
GO
/****** Object:  StoredProcedure [dbo].[royy_Bills]    Script Date: 03/31/2019 07:34:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[royy_Bills]  
	@booknumid varchar(50)
AS
SELECT convert(Varchar(50),fldBill) + '-' + convert(varchar,tblSession.fldTerminal) + @booknumid,
		datediff(mi, '01/01/1988', fldOpenTime), fldCustomerIdentity, fldCloseMode, fldCashier,@booknumid
		FROM tblTransBills tblTransBills WITH (NOLOCK)
		inner join  tblTransMain WITH (NOLOCK) 
				on tblTransMain.fldSequence = tblTransBills.fldSequence
				
		inner join  tblSession WITH (NOLOCK) 
				on tblSession.fldSessionID = tblTransMain.fldSessionID
		where tblTransBills.fldCloseMode in (0, 2)
		and fldOpenTime >= GETDATE() - 5


