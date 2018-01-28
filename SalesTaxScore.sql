DROP PROCEDURE IF EXISTS generate_sev_tax_py_model;
go
CREATE PROCEDURE generate_sev_tax_py_model (@trained_model varbinary(max) OUTPUT)
AS
BEGIN
    EXECUTE sp_execute_external_script
      @language = N'Python'
    , @script = N'
from sklearn.linear_model import LinearRegression
import pickle

df = sev_tax_train_data

# Get all the columns from the dataframe.
columns = df.columns.tolist()

# Store the variable well be predicting on.
target = "sev_tax"



# Initialize the model class.
lin_model = LinearRegression()

# Fit the model to the training data.
lin_model.fit(df[columns], df[target])

#Before saving the model to the DB table, we need to convert it to a binary object
trained_model = pickle.dumps(lin_model)'

, @input_data_1 = N'select "sev_tax","surface_lat","surface_long","total_depth","lateral_length","history_year","Actual_Oil","Actual_Gas","Actual_Water","cum_180_oil","cum_360_oil","cum_730_oil","cum_total_oil","cum_90_max_oil","cum_180_max_oil","cum_180_gas","cum_360_gas","cum_730_gas","cum_total_gas","cum_90_max_gas","cum_180_max_gas","cum_180_water","cum_360_water","cum_730_water","cum_total_water","cum_90_max_water","cum_180_max_water","Forecast Year","Forecast Days","oil","gas","water","qi_oil","b_oil","Di_oil","Di_eff_oil %","Dsw_oil","Dsw_eff_oil %","Error_fit_oil","t0_oil",	"Filter_t0_oil","t_end_oil","filter_t_end_oil","length_t_oil","length_filter_t_oil","Initial_oil_rate",	"Initial_Filter_oil_rate","q_forecast_end_oil","qi_gas","b_gas","Di_gas","Di_eff_gas %","Dsw_gas","Dsw_eff_gas %","Error_fit_gas","t0_gas","Filter_t0_gas","t_end_gas","filter_t_end_gas","length_t_gas","length_filter_t_gas","Initial_gas_rate","Initial_Filter_gas_rate","q_forecast_end_gas","qi_water","b_water","Di_water","Di_eff_water %","Dsw_water","Dsw_eff_water %","Error_fit_water","t0_water","Filter_t0_water","t_end_water","filter_t_end_water","length_t_water","length_filter_t_water","Initial_water_rate","Initial_Filter_water_rate","q_forecast_end_water","P10","P50","P90","EUR_mean","EUR_std_dev","oil_EUR","gas_EUR","water_EUR","oil_reserve","gas_reserve","net_oil_sales","net_gas_sales","net_water_costs","ad_val_tax","LOE","net_cash_flow","net_cum_cash_flow","net_cum_cash_flow_disc","NPV_disc","PI_disc","IRR","pet_index","remain_Forecast Year","remain_Forecast Days","remain_oil_reserve","remain_gas_reserve","remain_net_oil_sales","remain_net_gas_sales","remain_net_water_costs","remain_ad_val_tax","remain_sev_tax","remain_LOE","remain_net_cash_flow","remain_net_cum_cash_flow","remain_net_cum_cash_flow_disc","remain_NPV_disc","remain_PI_disc","remain_IRR","remain_pet_index","placer","cum_90_max_oil_original","cum_90_max_gas_original","cum_90_max_water_original","NGL_yield","gas_shrink","CGR","NPV_disc_high30_oilprice","IRR_high30_oilprice","rNPV_disc_high30_oilprice","rIRR_high30_oilprice","oil_reserve_high30_oilprice","gas_reserve_high30_oilprice","ngl_reserve_high30_oilprice","roil_reserve_high30_oilprice","rgas_reserve_high30_oilprice","rngl_reserve_high30_oilprice","NPV_disc_low30_oilprice","IRR_low30_oilprice","rNPV_disc_low30_oilprice","rIRR_low0_oilprice","oil_reserve_low30_oilprice","gas_reserve_low30_oilprice","ngl_reserve_low30_oilprice","roil_reserve_low30_oilprice","rgas_reserve_low30_oilprice","rngl_reserve_low30_oilprice","NPV_disc_high30_gasprice","IRR_high30_gasprice","rNPV_disc_high30_gasprice","rIRR_high30_gasprice","oil_reserve_high30_gasprice","gas_reserve_high30_gasprice","ngl_reserve_high30_gasprice","roil_reserve_high30_gasprice","rgas_reserve_high30_gasprice","rngl_reserve_high30_gasprice","NPV_disc_low30_gasprice","IRR_low30_gasprice","rNPV_disc_low30_gasprice","rIRR_low0_gasprice","oil_reserve_low30_gasprice","gas_reserve_low30_gasprice","ngl_reserve_low30_gasprice","roil_reserve_low30_gasprice","rgas_reserve_low30_gasprice","rngl_reserve_low30_gasprice","NPV_disc_high30_capex","IRR_high30_capex","rNPV_disc_high30_capex","rIRR_high30_capex","oil_reserve_high30_capex","gas_reserve_high30_capex","ngl_reserve_high30_capex","roil_reserve_high30_capex","rgas_reserve_high30_capex","rngl_reserve_high30_capex","NPV_disc_low30_capex","IRR_low30_capex","rNPV_disc_low30_capex","rIRR_low0_capex","oil_reserve_low30_capex","gas_reserve_low30_capex","ngl_reserve_low30_capex","roil_reserve_low30_capex","rgas_reserve_low30_capex","rngl_reserve_low30_capex","NPV_disc_high30_eur","IRR_high30_eur","rNPV_disc_high30_eur","rIRR_high30_eur","oil_reserve_high30_eur","gas_reserve_high30_eur","ngl_reserve_high30_eur","roil_reserve_high30_eur","rgas_reserve_high30_eur","rngl_reserve_high30_eur" from dbo.Eagleford where history_year < 2016'
, @input_data_1_name = N'sev_tax_train_data'
, @params = N'@trained_model varbinary(max) OUTPUT'
, @trained_model = @trained_model OUTPUT;
END;
GO


TRUNCATE TABLE sev_tax_py_models;

DECLARE @model VARBINARY(MAX);
EXEC generate_sev_tax_py_model @model OUTPUT;

INSERT INTO sev_tax_py_models (model_name, model) VALUES('linear_model', @model);