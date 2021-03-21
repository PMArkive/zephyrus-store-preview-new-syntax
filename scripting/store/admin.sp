#if defined STANDALONE_BUILD
#include <sourcemod>
#include <sdktools>

#include <store>
#include <zephstocks>

#endif

enum AdminItem
{
	String:szFlags[32],
	GroupId:nGroup,
	nImmunity
}

int g_eAdmins[STORE_MAX_ITEMS][AdminItem];
int g_iAdmins = 0;

public void AdminGroup_OnPluginStart()
{
	Store_RegisterHandler("admin", "group", AdminGroup_OnMapStart, AdminGroup_Reset, AdminGroup_Config, AdminGroup_Equip, AdminGroup_Remove, true);
}

public void AdminGroup_OnMapStart()
{
}

public void AdminGroup_Reset()
{
	g_iAdmins = 0;
}

public bool AdminGroup_Config(Handle &kv,int itemid)
{
	Store_SetDataIndex(itemid, g_iAdmins);

	char group[64];
	KvGetString(kv, "flags", g_eAdmins[g_iAdmins][szFlags], 32);
	KvGetString(kv, "group", STRING(group));

	g_eAdmins[g_iAdmins][nGroup]=FindAdmGroup(group);
	g_eAdmins[g_iAdmins][nImmunity]=KvGetNum(kv, "immunity");

	++g_iAdmins;
	return true;
}

public int AdminGroup_Equip(int client,int id)
{
	int data = Store_GetDataIndex(id);

	AdminId Admin = view_as<AdminId>(GetUserAdmin(client));
	if(Admin == INVALID_ADMIN_ID)
	{
		Admin = CreateAdmin();
		SetUserAdmin(client, Admin);
	}

	if(g_eAdmins[data][nGroup] != INVALID_GROUP_ID)
		AdminInheritGroup(Admin, g_eAdmins[data][nGroup]);

	if(GetAdminImmunityLevel(Admin) < g_eAdmins[data][nImmunity])
		SetAdminImmunityLevel(Admin,  g_eAdmins[data][nImmunity]);

	char tmp[32];
	strcopy(STRING(tmp), g_eAdmins[data][szFlags]);
	any len = strlen(tmp);
	//any AdminFlag:flag;
	any flag = ReadFlagString(g_eAdmins[data][szFlags]);
	for (int i=0; i<len; i++)
	{
		if (!FindFlagByChar(tmp[i], flag))
			continue;
		SetAdminFlag(Admin, view_as<AdminFlag>(flag), true);
	}

	RunAdminCacheChecks(client);

	return -1;
}

public int AdminGroup_Remove(int client,int id)
{
}