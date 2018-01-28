DROP PROCEDURE IF EXISTS py_predict_sev_tax;
GO
CREATE PROCEDURE py_predict_sev_tax (@model varchar(100))
AS
BEGIN
	DECLARE @py_model varbinary(max) = (select model from sev_tax_py_models where model_name = @model);

	EXEC sp_execute_external_script
				@language = N'Python',
				@script = N'

# Import the scikit-learn function to compute error.
from sklearn.metrics import mean_squared_error
import pickle
import pandas as pd

sev_tax_model = pickle.loads(py_model)

df = sev_tax_score_data

# Get all the columns from the dataframe.
columns = df.columns.tolist()

# variable we will be predicting on.
target = "sev_tax"

# Generate our predictions for the test set.
lin_predictions = sev_tax_model.predict(df[columns])
print(lin_predictions)

# Compute error between our test predictions and the actual values.
lin_mse = mean_squared_error(lin_predictions, df[target])
#print(lin_mse)

predictions_df = pd.DataFrame(lin_predictions)

OutputDataSet = pd.concat([predictions_df, df["sev_tax"],df["surface_lat"],df["surface_long"],df["total_depth"],df["lateral_length"],df["history_year"],df["Actual_Oil"],df["Actual_Gas"],df["Actual_Water"],df["cum_180_oil"],df["cum_360_oil"],df["cum_730_oil"],df["cum_total_oil"],df["cum_90_max_oil"],df["cum_180_max_oil"],df["cum_180_gas"],df["cum_360_gas"],df["cum_730_gas"],df["cum_total_gas"],df["cum_90_max_gas"],df["cum_180_max_gas"],df["cum_180_water"],df["cum_360_water"],df["cum_730_water"],df["cum_total_water"],df["cum_90_max_water"],df["cum_180_max_water"],df["Forecast Year"],df["Forecast Days"],df["oil"],df["gas"],df["water"],df["qi_oil"],df["b_oil"],df["Di_oil"],df["Di_eff_oil %"],df["Dsw_oil"],df["Dsw_eff_oil %"],df["Error_fit_oil"],df["t0_oil"],df["Filter_t0_oil"],df["t_end_oil"],df["filter_t_end_oil"],df["length_t_oil"],df["length_filter_t_oil"],df["Initial_oil_rate"],df["Initial_Filter_oil_rate"],df["q_forecast_end_oil"],df["qi_gas"],df["b_gas"],df["Di_gas"],df["Di_eff_gas %"],df["Dsw_gas"],df["Dsw_eff_gas %"],df["Error_fit_gas"],df["t0_gas"],df["Filter_t0_gas"],df["t_end_gas"],df["filter_t_end_gas"],df["length_t_gas"],df["length_filter_t_gas"],df["Initial_gas_rate"],df["Initial_Filter_gas_rate"],df["q_forecast_end_gas"],df["qi_water"],df["b_water"],df["Di_water"],df["Di_eff_water %"],df["Dsw_water"],df["Dsw_eff_water %"],df["Error_fit_water"],df["t0_water"],df["Filter_t0_water"],df["t_end_water"],df["filter_t_end_water"],df["length_t_water"],df["length_filter_t_water"],df["Initial_water_rate"],df["Initial_Filter_water_rate"],df["q_forecast_end_water"],df["P10"],df["P50"],df["P90"],df["EUR_mean"],df["EUR_std_dev"],df["oil_EUR"],df["gas_EUR"],df["water_EUR"],df["oil_reserve"],df["gas_reserve"],df["net_oil_sales"],df["net_gas_sales"],df["net_water_costs"],df["ad_val_tax"],df["LOE"],df["net_cash_flow"],df["net_cum_cash_flow"],df["net_cum_cash_flow_disc"],df["NPV_disc"],df["PI_disc"],df["IRR"],df["pet_index"],df["remain_Forecast Year"],df["remain_Forecast Days"],df["remain_oil_reserve"],df["remain_gas_reserve"],df["remain_net_oil_sales"],df["remain_net_gas_sales"],df["remain_net_water_costs"],df["remain_ad_val_tax"],df["remain_sev_tax"],df["remain_LOE"],df["remain_net_cash_flow"],df["remain_net_cum_cash_flow"],df["remain_net_cum_cash_flow_disc"],df["remain_NPV_disc"],df["remain_PI_disc"],df["remain_IRR"],df["remain_pet_index"],df["placer"],df["cum_90_max_oil_original"],df["cum_90_max_gas_original"],df["cum_90_max_water_original"],df["NGL_yield"],df["gas_shrink"],df["CGR"],df["NPV_disc_high30_oilprice"],df["IRR_high30_oilprice"],df["rNPV_disc_high30_oilprice"],df["rIRR_high30_oilprice"],df["oil_reserve_high30_oilprice"],df["gas_reserve_high30_oilprice"],df["ngl_reserve_high30_oilprice"],df["roil_reserve_high30_oilprice"],df["rgas_reserve_high30_oilprice"],df["rngl_reserve_high30_oilprice"],df["NPV_disc_low30_oilprice"],df["IRR_low30_oilprice"],df["rNPV_disc_low30_oilprice"],df["rIRR_low0_oilprice"],df["oil_reserve_low30_oilprice"],df["gas_reserve_low30_oilprice"],df["ngl_reserve_low30_oilprice"],df["roil_reserve_low30_oilprice"],df["rgas_reserve_low30_oilprice"],df["rngl_reserve_low30_oilprice"],df["NPV_disc_high30_gasprice"],df["IRR_high30_gasprice"],df["rNPV_disc_high30_gasprice"],df["rIRR_high30_gasprice"],df["oil_reserve_high30_gasprice"],df["gas_reserve_high30_gasprice"],df["ngl_reserve_high30_gasprice"],df["roil_reserve_high30_gasprice"],df["rgas_reserve_high30_gasprice"],df["rngl_reserve_high30_gasprice"],df["NPV_disc_low30_gasprice"],df["IRR_low30_gasprice"],df["rNPV_disc_low30_gasprice"],df["rIRR_low0_gasprice"],df["oil_reserve_low30_gasprice"],df["gas_reserve_low30_gasprice"],df["ngl_reserve_low30_gasprice"],df["roil_reserve_low30_gasprice"],df["rgas_reserve_low30_gasprice"],df["rngl_reserve_low30_gasprice"],df["NPV_disc_high30_capex"],df["IRR_high30_capex"],df["rNPV_disc_high30_capex"],df["rIRR_high30_capex"],df["oil_reserve_high30_capex"],df["gas_reserve_high30_capex"],df["ngl_reserve_high30_capex"],df["roil_reserve_high30_capex"],df["rgas_reserve_high30_capex"],df["rngl_reserve_high30_capex"],df["NPV_disc_low30_capex"],df["IRR_low30_capex"],df["rNPV_disc_low30_capex"],df["rIRR_low0_capex"],df["oil_reserve_low30_capex"],df["gas_reserve_low30_capex"],df["ngl_reserve_low30_capex"],df["roil_reserve_low30_capex"],df["rgas_reserve_low30_capex"],df["rngl_reserve_low30_capex"],df["NPV_disc_high30_eur"],df["IRR_high30_eur"],df["rNPV_disc_high30_eur"],df["rIRR_high30_eur"],df["oil_reserve_high30_eur"],df["gas_reserve_high30_eur"],df["ngl_reserve_high30_eur"],df["roil_reserve_high30_eur"],df["rgas_reserve_high30_eur"],df["rngl_reserve_high30_eur"]],axis=1)
'
, @input_data_1 = N'Select "sev_tax","surface_lat","surface_long","total_depth","lateral_length","history_year","Actual_Oil","Actual_Gas","Actual_Water","cum_180_oil","cum_360_oil","cum_730_oil","cum_total_oil","cum_90_max_oil","cum_180_max_oil","cum_180_gas","cum_360_gas","cum_730_gas","cum_total_gas","cum_90_max_gas","cum_180_max_gas","cum_180_water","cum_360_water","cum_730_water","cum_total_water","cum_90_max_water","cum_180_max_water","Forecast Year","Forecast Days","oil","gas","water","qi_oil","b_oil","Di_oil","Di_eff_oil %","Dsw_oil","Dsw_eff_oil %","Error_fit_oil","t0_oil",	"Filter_t0_oil","t_end_oil","filter_t_end_oil","length_t_oil","length_filter_t_oil","Initial_oil_rate",	"Initial_Filter_oil_rate","q_forecast_end_oil","qi_gas","b_gas","Di_gas","Di_eff_gas %","Dsw_gas","Dsw_eff_gas %","Error_fit_gas","t0_gas","Filter_t0_gas","t_end_gas","filter_t_end_gas","length_t_gas","length_filter_t_gas","Initial_gas_rate","Initial_Filter_gas_rate","q_forecast_end_gas","qi_water","b_water","Di_water","Di_eff_water %","Dsw_water","Dsw_eff_water %","Error_fit_water","t0_water","Filter_t0_water","t_end_water","filter_t_end_water","length_t_water","length_filter_t_water","Initial_water_rate","Initial_Filter_water_rate","q_forecast_end_water","P10","P50","P90","EUR_mean","EUR_std_dev","oil_EUR","gas_EUR","water_EUR","oil_reserve","gas_reserve","net_oil_sales","net_gas_sales","net_water_costs","ad_val_tax","LOE","net_cash_flow","net_cum_cash_flow","net_cum_cash_flow_disc","NPV_disc","PI_disc","IRR","pet_index","remain_Forecast Year","remain_Forecast Days","remain_oil_reserve","remain_gas_reserve","remain_net_oil_sales","remain_net_gas_sales","remain_net_water_costs","remain_ad_val_tax","remain_sev_tax","remain_LOE","remain_net_cash_flow","remain_net_cum_cash_flow","remain_net_cum_cash_flow_disc","remain_NPV_disc","remain_PI_disc","remain_IRR","remain_pet_index","placer","cum_90_max_oil_original","cum_90_max_gas_original","cum_90_max_water_original","NGL_yield","gas_shrink","CGR","NPV_disc_high30_oilprice","IRR_high30_oilprice","rNPV_disc_high30_oilprice","rIRR_high30_oilprice","oil_reserve_high30_oilprice","gas_reserve_high30_oilprice","ngl_reserve_high30_oilprice","roil_reserve_high30_oilprice","rgas_reserve_high30_oilprice","rngl_reserve_high30_oilprice","NPV_disc_low30_oilprice","IRR_low30_oilprice","rNPV_disc_low30_oilprice","rIRR_low0_oilprice","oil_reserve_low30_oilprice","gas_reserve_low30_oilprice","ngl_reserve_low30_oilprice","roil_reserve_low30_oilprice","rgas_reserve_low30_oilprice","rngl_reserve_low30_oilprice","NPV_disc_high30_gasprice","IRR_high30_gasprice","rNPV_disc_high30_gasprice","rIRR_high30_gasprice","oil_reserve_high30_gasprice","gas_reserve_high30_gasprice","ngl_reserve_high30_gasprice","roil_reserve_high30_gasprice","rgas_reserve_high30_gasprice","rngl_reserve_high30_gasprice","NPV_disc_low30_gasprice","IRR_low30_gasprice","rNPV_disc_low30_gasprice","rIRR_low0_gasprice","oil_reserve_low30_gasprice","gas_reserve_low30_gasprice","ngl_reserve_low30_gasprice","roil_reserve_low30_gasprice","rgas_reserve_low30_gasprice","rngl_reserve_low30_gasprice","NPV_disc_high30_capex","IRR_high30_capex","rNPV_disc_high30_capex","rIRR_high30_capex","oil_reserve_high30_capex","gas_reserve_high30_capex","ngl_reserve_high30_capex","roil_reserve_high30_capex","rgas_reserve_high30_capex","rngl_reserve_high30_capex","NPV_disc_low30_capex","IRR_low30_capex","rNPV_disc_low30_capex","rIRR_low0_capex","oil_reserve_low30_capex","gas_reserve_low30_capex","ngl_reserve_low30_capex","roil_reserve_low30_capex","rgas_reserve_low30_capex","rngl_reserve_low30_capex","NPV_disc_high30_eur","IRR_high30_eur","rNPV_disc_high30_eur","rIRR_high30_eur","oil_reserve_high30_eur","gas_reserve_high30_eur","ngl_reserve_high30_eur","roil_reserve_high30_eur","rgas_reserve_high30_eur","rngl_reserve_high30_eur" from dbo.Eagleford where history_year < 2016'
, @input_data_1_name = N'sev_tax_score_data'
, @params = N'@py_model varbinary(max)'
, @py_model = @py_model
with result sets (("sev_tax_Predicted" float, "sev_tax" float,"surface_lat" float,"surface_long" float,"total_depth" float,"lateral_length" float,"history_year" float,"Actual_Oil" float,"Actual_Gas" float,"Actual_Water" float,"cum_180_oil" float,"cum_360_oil" float,"cum_730_oil" float,"cum_total_oil" float,"cum_90_max_oil" float,"cum_180_max_oil" float,"cum_180_gas" float,"cum_360_gas" float,"cum_730_gas" float,"cum_total_gas" float,"cum_90_max_gas" float,"cum_180_max_gas" float,"cum_180_water" float,"cum_360_water" float,"cum_730_water" float,"cum_total_water" float,"cum_90_max_water" float,"cum_180_max_water" float,"Forecast Year" float,"Forecast Days" float,"oil" float,"gas" float,"water" float,"qi_oil" float,"b_oil" float,"Di_oil" float,"Di_eff_oil %" float,"Dsw_oil" float,"Dsw_eff_oil %" float,"Error_fit_oil" float,"t0_oil" float,	"Filter_t0_oil" float,"t_end_oil" float,"filter_t_end_oil" float,"length_t_oil" float,"length_filter_t_oil" float,"Initial_oil_rate" float,"Initial_Filter_oil_rate" float,"q_forecast_end_oil" float,"qi_gas" float,"b_gas" float,"Di_gas" float,"Di_eff_gas %" float,"Dsw_gas" float,"Dsw_eff_gas %" float,"Error_fit_gas" float,"t0_gas" float,"Filter_t0_gas" float,"t_end_gas" float,"filter_t_end_gas" float,"length_t_gas" float,"length_filter_t_gas" float,"Initial_gas_rate" float,"Initial_Filter_gas_rate" float,"q_forecast_end_gas" float,"qi_water" float,"b_water" float,"Di_water" float,"Di_eff_water %" float,"Dsw_water" float,"Dsw_eff_water %" float,"Error_fit_water" float,"t0_water" float,"Filter_t0_water" float,"t_end_water" float,"filter_t_end_water" float,"length_t_water" float,"length_filter_t_water" float,"Initial_water_rate" float,"Initial_Filter_water_rate" float,"q_forecast_end_water" float,"P10" float,"P50" float,"P90" float,"EUR_mean" float,"EUR_std_dev" float,"oil_EUR" float,"gas_EUR" float,"water_EUR" float,"oil_reserve" float,"gas_reserve" float,"net_oil_sales" float,"net_gas_sales" float,"net_water_costs" float,"ad_val_tax" float,"LOE" float,"net_cash_flow" float,"net_cum_cash_flow" float,"net_cum_cash_flow_disc" float,"NPV_disc" float,"PI_disc" float,"IRR" float,"pet_index" float,"remain_Forecast Year" float,"remain_Forecast Days" float,"remain_oil_reserve" float,"remain_gas_reserve" float,"remain_net_oil_sales" float,"remain_net_gas_sales" float,"remain_net_water_costs" float,"remain_ad_val_tax" float,"remain_sev_tax" float,"remain_LOE" float,"remain_net_cash_flow" float,"remain_net_cum_cash_flow" float,"remain_net_cum_cash_flow_disc" float,"remain_NPV_disc" float,"remain_PI_disc" float,"remain_IRR" float,"remain_pet_index" float,"placer" float,"cum_90_max_oil_original" float,"cum_90_max_gas_original" float,"cum_90_max_water_original" float,"NGL_yield" float,"gas_shrink" float,"CGR" float,"NPV_disc_high30_oilprice" float,"IRR_high30_oilprice" float,"rNPV_disc_high30_oilprice" float,"rIRR_high30_oilprice" float,"oil_reserve_high30_oilprice" float,"gas_reserve_high30_oilprice" float,"ngl_reserve_high30_oilprice" float,"roil_reserve_high30_oilprice" float,"rgas_reserve_high30_oilprice" float,"rngl_reserve_high30_oilprice" float,"NPV_disc_low30_oilprice" float,"IRR_low30_oilprice" float,"rNPV_disc_low30_oilprice" float,"rIRR_low0_oilprice" float,"oil_reserve_low30_oilprice" float,"gas_reserve_low30_oilprice" float,"ngl_reserve_low30_oilprice" float,"roil_reserve_low30_oilprice" float,"rgas_reserve_low30_oilprice" float,"rngl_reserve_low30_oilprice" float,"NPV_disc_high30_gasprice" float,"IRR_high30_gasprice" float,"rNPV_disc_high30_gasprice" float,"rIRR_high30_gasprice" float,"oil_reserve_high30_gasprice" float,"gas_reserve_high30_gasprice" float,"ngl_reserve_high30_gasprice" float,"roil_reserve_high30_gasprice" float,"rgas_reserve_high30_gasprice" float,"rngl_reserve_high30_gasprice" float,"NPV_disc_low30_gasprice" float,"IRR_low30_gasprice" float,"rNPV_disc_low30_gasprice" float,"rIRR_low0_gasprice" float,"oil_reserve_low30_gasprice" float,"gas_reserve_low30_gasprice" float,"ngl_reserve_low30_gasprice" float,"roil_reserve_low30_gasprice" float,"rgas_reserve_low30_gasprice" float,"rngl_reserve_low30_gasprice" float,"NPV_disc_high30_capex" float,"IRR_high30_capex" float,"rNPV_disc_high30_capex" float,"rIRR_high30_capex" float,"oil_reserve_high30_capex" float,"gas_reserve_high30_capex" float,"ngl_reserve_high30_capex" float,"roil_reserve_high30_capex" float,"rgas_reserve_high30_capex" float,"rngl_reserve_high30_capex" float,"NPV_disc_low30_capex" float,"IRR_low30_capex" float,"rNPV_disc_low30_capex" float,"rIRR_low0_capex" float,"oil_reserve_low30_capex" float,"gas_reserve_low30_capex" float,"ngl_reserve_low30_capex" float,"roil_reserve_low30_capex" float,"rgas_reserve_low30_capex" float,"rngl_reserve_low30_capex" float,"NPV_disc_high30_eur" float,"IRR_high30_eur" float,"rNPV_disc_high30_eur" float,"rIRR_high30_eur" float,"oil_reserve_high30_eur" float,"gas_reserve_high30_eur" float,"ngl_reserve_high30_eur" float,"roil_reserve_high30_eur" float,"rgas_reserve_high30_eur" float,"rngl_reserve_high30_eur" float));

END;
GO

TRUNCATE TABLE py_sev_tax_predictions;
--Insert the results of the predictions for test set into a table
INSERT INTO py_sev_tax_predictions
EXEC py_predict_sev_tax 'linear_model';



-- Select contents of the table
SELECT * FROM py_sev_tax_predictions;