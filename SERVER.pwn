new ServerMoney, //2255.92, -1747.33, 1014.77
	Material,
	MaterialPrice,
	LumberPrice,
	Component,
	ComponentPrice,
	MetalPrice,
	GasOil,
	GasOilPrice,
	CoalPrice,
	Product,
	ProductPrice,
	Apotek,
	MedicinePrice,
	MedkitPrice,
	Food,
	FoodPrice,
	SeedPrice,
	PotatoPrice,
	WheatPrice,
	OrangePrice,
	Marijuana,
	MarijuanaPrice,
	FishPrice,
	GStationPrice;
	
new MoneyPickup,
	Text3D:MoneyText,
	MatPickup,
	Text3D:MatText,
	CompPickup,
	GasOilPickup,
	Text3D:GasOilText,
	OrePickup,
	Text3D:OreText,
	ProductPickup,
	Text3D:ProductText,
	ApotekPickup,
	Text3D:ApotekText,
	FoodPickup,
	Text3D:FoodText,
	DrugPickup,
	Text3D:DrugText,
	Text3D:CompText;
	
CreateServerPoint()
{
	if(IsValidDynamic3DTextLabel(MoneyText))
            DestroyDynamic3DTextLabel(MoneyText);

	if(IsValidDynamicPickup(MoneyPickup))
		DestroyDynamicPickup(MoneyPickup);
			
	//Server Money
	new strings[1024];
	MoneyPickup = CreateDynamicPickup(1239, 23, 2255.92, -1747.33, 1014.77, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[Server Money]\n"WHITE_E"Goverment Money: "LG_E"%s", FormatMoney(ServerMoney));
	MoneyText = CreateDynamic3DTextLabel(strings, COLOR_LBLUE, 2255.92, -1747.33, 1014.77, 5.0);
	
	if(IsValidDynamic3DTextLabel(MatText))
            DestroyDynamic3DTextLabel(MatText);

	if(IsValidDynamicPickup(MatPickup))
		DestroyDynamicPickup(MatPickup);
	
	if(IsValidDynamic3DTextLabel(CompText))
            DestroyDynamic3DTextLabel(CompText);

	if(IsValidDynamicPickup(CompPickup))
		DestroyDynamicPickup(CompPickup);
	
	if(IsValidDynamic3DTextLabel(GasOilText))
            DestroyDynamic3DTextLabel(GasOilText);

	if(IsValidDynamicPickup(GasOilPickup))
		DestroyDynamicPickup(GasOilPickup);
		
	if(IsValidDynamic3DTextLabel(OreText))
            DestroyDynamic3DTextLabel(OreText);

	if(IsValidDynamicPickup(OrePickup))
		DestroyDynamicPickup(OrePickup);
		
	if(IsValidDynamic3DTextLabel(ProductText))
            DestroyDynamic3DTextLabel(ProductText);
		
	if(IsValidDynamicPickup(ProductPickup))
		DestroyDynamicPickup(ProductPickup);

	if(IsValidDynamic3DTextLabel(ApotekText))
            DestroyDynamic3DTextLabel(ApotekText);
		
	if(IsValidDynamicPickup(ApotekPickup))
		DestroyDynamicPickup(ApotekPickup);
	
	if(IsValidDynamic3DTextLabel(FoodText))
            DestroyDynamic3DTextLabel(FoodText);
		
	if(IsValidDynamicPickup(FoodPickup))
		DestroyDynamicPickup(FoodPickup);
		
	if(IsValidDynamic3DTextLabel(DrugText))
            DestroyDynamic3DTextLabel(DrugText);
		
	if(IsValidDynamicPickup(DrugPickup))
		DestroyDynamicPickup(DrugPickup);
	if(IsValidDynamic3DTextLabel(CompText))
	    DestroyDynamic3DTextLabel(CompText);
	
		
	//JOBS
	MatPickup = CreateDynamicPickup(1239, 23, -258.54, -2189.92, 28.97, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[Material]\n"WHITE_E"Material Stock: "LG_E"%d\n\n"WHITE_E"Material Price: "LG_E"%s /item\n\n"WHITE_E"Lumber Price: "LG_E"%s /item\n"LB_E"/buy", Material, FormatMoney(MaterialPrice), FormatMoney(LumberPrice));
	MatText = CreateDynamic3DTextLabel(strings, COLOR_YELLOW, -258.54, -2189.92, 28.97, 5.0); // lumber
	
	CompPickup = CreateDynamicPickup(2912, 23, 315.07, 926.53, 20.46, -1);
	format(strings, sizeof(strings), "[Miner]\n"WHITE_E"CrateRawComponent"LG_E"\n"LB_E"/getcrate");
	CompText = CreateDynamic3DTextLabel(strings, COLOR_YELLOW, 315.07, 926.53, 20.46, 5.0); // comp
	
	//BuyComponent By GloryRP
	new comp[256];
	CreateDynamicPickup(1239, 23, 854.6003, -605.2056, 18.4219, -1); // komponen
 	format(comp, sizeof(comp), "[Component Storage]\nComponent Stock : %d\nComponent Price : $5\n'/buy' untuk membeli Komponen", StockComp);
    CompText = CreateDynamic3DTextLabel(comp, COLOR_YELLOW, 854.6003, -605.2056, 18.4219, 10);
    
    //Unload CrateByGloryRP
    new unloadcrate[250];
    CreateDynamicPickup(2912, 23, 797.6823, -617.5379, 16.3359, -1);
    format(unloadcrate, sizeof(unloadcrate), "[Component Storage]\n"YELLOW_E"Unload Crate\n/unloadcrate");
	CreateDynamic3DTextLabel(unloadcrate, COLOR_YELLOW, 797.6823, -617.5379, 16.3359, 10);
    
	GasOilPickup = CreateDynamicPickup(1239, 23, 336.70, 895.54, 20.40, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[Miner]\n"WHITE_E"GasOil Stock: "LG_E"%d liters\n\n"WHITE_E"GasOil Price: "LG_E"%s /liters\n"LB_E"/buy", GasOil, FormatMoney(GasOilPrice));
	GasOilText = CreateDynamic3DTextLabel(strings, COLOR_YELLOW, 336.70, 895.54, 20.40, 5.0); // gasoil
	
	OrePickup = CreateDynamicPickup(1239, 23, 293.73, 913.17, 20.40, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[Miner]\n"WHITE_E"Ore Metal Price: "LG_E"%s / item\n\n"WHITE_E"Ore Coal Price: "LG_E"%s /item\n"LB_E"/ore sell", FormatMoney(MetalPrice), FormatMoney(CoalPrice));
	OreText = CreateDynamic3DTextLabel(strings, COLOR_YELLOW, 293.73, 913.17, 20.40, 5.0); // sell ore
	
	ProductPickup = CreateDynamicPickup(1239, 23, -279.67, -2148.42, 28.54, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[PRODUCT]\n"WHITE_E"Product Stock: "LG_E"%d\n\n"WHITE_E"Product Price: "LG_E"%s /item\n"LB_E"/buy /sellproduct", Product, FormatMoney(ProductPrice));
	ProductText = CreateDynamic3DTextLabel(strings, COLOR_YELLOW, -279.67, -2148.42, 28.54, 5.0); // product
	
	ApotekPickup = CreateDynamicPickup(1239, 23, 1435.34, -23.91, 1000.92, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[Hospital]\n"WHITE_E"Apotek Stock: "LG_E"%d\n"LB_E"/buy", Apotek);
	ApotekText = CreateDynamic3DTextLabel(strings, COLOR_PINK, 1435.34, -23.91, 1000.92, 5.0); // Apotek hospital
	
	FoodPickup = CreateDynamicPickup(1239, 23, -381.44, -1426.13, 25.93, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[Food]\n"WHITE_E"Food Stock: "LG_E"%d\n"WHITE_E"Food Price: "LG_E"%s /item\n\n"WHITE_E"Seed Price: "LG_E"%s /item\n"WHITE_E"Potato Price: "LG_E"%s /kg\n"WHITE_E"Wheat Price: "LG_E"%s /kg\n"WHITE_E"Orange Price: "LG_E"%s /kg\n\n"WHITE_E"Fish Price: "LG_E"%s /kg\n"LB_E"/buy /sellfish", 
	Food, FormatMoney(FoodPrice), FormatMoney(SeedPrice), FormatMoney(PotatoPrice), FormatMoney(WheatPrice), FormatMoney(OrangePrice), FormatMoney(FishPrice));
	FoodText = CreateDynamic3DTextLabel(strings, COLOR_YELLOW, -381.44, -1426.13 , 25.93+1, 5.0); // food
	
	DrugPickup = CreateDynamicPickup(1239, 23, -3811.65, 1313.72, 71.42, -1, -1, -1, 5.0);
	format(strings, sizeof(strings), "[Black Market]\n"WHITE_E"Marijuana Stock: "LG_E"%d\n\n"WHITE_E"Marijuana Price: "LG_E"%s /item\n"LB_E"/buy /sellmarijuana", Marijuana, FormatMoney(MarijuanaPrice));
	DrugText = CreateDynamic3DTextLabel(strings, COLOR_GREY, -3811.65, 1313.72, 71.42, 5.0); // product
}

Server_Percent(price)
{
    return floatround((float(price) / 100) * 85);
}

Server_AddPercent(price)
{
    new money = (price - Server_Percent(price));
    ServerMoney = ServerMoney + money;
    Server_Save();
}

Server_AddMoney(amount)
{
    ServerMoney = ServerMoney + amount;
    Server_Save();
}

Server_MinMoney(amount)
{
    ServerMoney -= amount;
    Server_Save();
}

Server_Save()
{
    new str[2024];

	CreateServerPoint();
    format(str, sizeof(str), "UPDATE server SET servermoney='%d', material='%d', materialprice='%d', lumberprice='%d', component='%d', componentprice='%d', metalprice='%d', gasoil='%d', gasoilprice='%d', coalprice='%d', product='%d', productprice='%d', medicineprice='%d', medkitprice='%d', food='%d', foodprice='%d', seedprice='%d', potatoprice='%d', wheatprice='%d', orangeprice='%d', marijuana='%d', marijuanaprice='%d', fishprice='%d', gstationprice='%d' WHERE id=0",
	ServerMoney, Material, MaterialPrice, LumberPrice, Component, ComponentPrice, MetalPrice, GasOil, GasOilPrice, CoalPrice, Product, ProductPrice, MedicinePrice, MedkitPrice, 
	Food, FoodPrice, SeedPrice, PotatoPrice, WheatPrice, OrangePrice, Marijuana, MarijuanaPrice, FishPrice, GStationPrice);
    return mysql_tquery(g_SQL, str);
}

function LoadServer()
{
	cache_get_value_name_int(0, "servermoney", ServerMoney);
	cache_get_value_name_int(0, "material", Material);
	cache_get_value_name_int(0, "materialprice", MaterialPrice);
	cache_get_value_name_int(0, "lumberprice", LumberPrice);
	cache_get_value_name_int(0, "component", Component);
	cache_get_value_name_int(0, "componentprice", ComponentPrice);
	cache_get_value_name_int(0, "metalprice", MetalPrice);
	cache_get_value_name_int(0, "gasoil", GasOil);
	cache_get_value_name_int(0, "gasoilprice", GasOilPrice);
	cache_get_value_name_int(0, "coalprice", CoalPrice);
	cache_get_value_name_int(0, "product", Product);
	cache_get_value_name_int(0, "productprice", ProductPrice);
	cache_get_value_name_int(0, "apotek", Apotek);
	cache_get_value_name_int(0, "medicineprice", MedicinePrice);
	cache_get_value_name_int(0, "medkitprice", MedkitPrice);
	cache_get_value_name_int(0, "food", Food);
	cache_get_value_name_int(0, "foodprice", FoodPrice);
	cache_get_value_name_int(0, "seedprice", SeedPrice);
	cache_get_value_name_int(0, "potatoprice", PotatoPrice);
	cache_get_value_name_int(0, "wheatprice", WheatPrice);
	cache_get_value_name_int(0, "orangeprice", OrangePrice);
	cache_get_value_name_int(0, "marijuana", Marijuana);
	cache_get_value_name_int(0, "marijuanaprice", MarijuanaPrice);
	cache_get_value_name_int(0, "fishprice", FishPrice);
	cache_get_value_name_int(0, "gstationprice", GStationPrice);
	printf("[Server] Number of Loaded Data Server...");
	printf("[Server] ServerMoney: %d", ServerMoney);
	//printf("[Server] Material: %d", Material);
	//printf("[Server] MaterialPrice: %d", MaterialPrice);
	//printf("[Server] LumberPrice: %d", LumberPrice);
	
	CreateServerPoint();
}
