USE ML
GO
--TRUNCATE TABLE [PredictiveMaintenance].[PM_Models] 
--TRUNCATE TABLE [PredictiveMaintenance].[Regression_metrics]
GO

SELECT * 
FROM [PredictiveMaintenance].[Regression_metrics]
ORDER BY [Relative Squared Error] 
GO

EXEC sp_helptext'[PredictiveMaintenance].[TrainRegressionModel]'
GO
DELETE FROM [PredictiveMaintenance].[PM_Models]	
WHERE model_name IN('rxFastForest regression','rxNeuralNet regression') 
GO

DECLARE @model VARBINARY(MAX);
EXEC [PredictiveMaintenance].[TrainRegressionModel] 'rxFastForest','[PredictiveMaintenance].[train_Features]', 35,
	 @model OUTPUT;
INSERT INTO [PredictiveMaintenance].[PM_Models] (model_name, model) VALUES('rxFastForest regression', @model);
GO

DECLARE @model VARBINARY(MAX);
EXEC [PredictiveMaintenance].[TrainRegressionModel] 'rxNeuralNet','[PredictiveMaintenance].[train_Features]', 35,
	 @model OUTPUT;
INSERT INTO [PredictiveMaintenance].[PM_Models] (model_name, model) VALUES('rxNeuralNet regression', @model);
GO

--Real-time scoring
sp_configure 'clr enabled', 1  
GO  
RECONFIGURE  
GO  

--C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\R_SERVICES\library\RevoScaleR\rxLibs\x64>RegisterRExt.exe /installRts /database:ML


DECLARE @model varbinary(max) = ( SELECT model FROM [PredictiveMaintenance].[PM_Models] 
WHERE model_name = 'rxFastForest regression');
EXEC sp_rxPredict
	@model = @model,
	@inputData = N'SELECT RUL , a4 , a11 , a21 , a15 , a20 , a17 , a12 , a7 , a2 , 
    a3 , s11 , s4 , s12 , s7 , s15 , s21 , s20 , s2 , s17 , a8 , 
    a13 , s3 , s8 , s13 , a9 , s9 , a14 , s14 , sd6 , a6 , s6 , 
    sd14 , sd9 , sd13, sd11 FROM [PredictiveMaintenance].[test_Features]'
GO

DECLARE @model varbinary(max) = ( SELECT model FROM [PredictiveMaintenance].[PM_Models] 
WHERE model_name = 'rxNeuralNet regression');
EXEC sp_rxPredict
	@model = @model,
	@inputData = N'SELECT RUL , a4 , a11 , a21 , a15 , a20 , a17 , a12 , a7 , a2 , 
    a3 , s11 , s4 , s12 , s7 , s15 , s21 , s20 , s2 , s17 , a8 , 
    a13 , s3 , s8 , s13 , a9 , s9 , a14 , s14 , sd6 , a6 , s6 , 
    sd14 , sd9 , sd13, sd11 FROM [PredictiveMaintenance].[test_Features]'
GO
