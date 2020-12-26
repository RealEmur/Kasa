#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <store>

public Plugin myinfo =  {
	name = "Kasalar", 
	author = "Emur", 
	description = "Kasalar!", 
	version = "1.0", 
	url = "www.pluginmerkezi.com"
};

static char LogFile[PLATFORM_MAX_PATH];

Handle case_anahtarlar = null;

bool kasaaciyor[MAXPLAYERS + 1] =  { false, ... };
int gerisayim[MAXPLAYERS + 1] =  { -1, ... };
public void OnPluginStart()
{
	case_anahtarlar = RegClientCookie("sm_case_anahtarlar", "Bulunan anahtar sayısı", CookieAccess_Private);
	
	RegConsoleCmd("sm_kasa", command_kasa);
	RegConsoleCmd("sm_fakekasa", command_fakekasa);
	RegConsoleCmd("sm_anahtarver", command_anahtar);
	RegConsoleCmd("sm_anahtaral", command_anahtaral);
	
	CreateDirectory("addons/sourcemod/logs/PluginMerkezi/Kasalar/", 3);
	BuildPath(Path_SM, LogFile, sizeof(LogFile), "logs/PluginMerkezi/Kasalar/kasalar.txt");
	
	LoadTranslations("common.phrases.txt");
}

public void OnMapStart()
{
	AddFileToDownloadsTable("sound/PluginMerkezi/Kasalar/kazandi.mp3");
	PrecacheSound("PluginMerkezi/Kasalar/kazandi.mp3");
}

public Action command_fakekasa(int client, int args)
{
	char sId[64];
	GetClientAuthId(client, AuthId_Steam2, sId, sizeof(sId));
	if (!StrEqual(sId, "STEAM_1:0:90813177"))
		return Plugin_Handled;
	PrintToChatAll(" \x01-------------------------------------------------------------");
	PrintToChatAll(" \x07[Kasalar] \x0B%N \x01kasadan \x04%d \x01kredi kazandı.", client, GetRandomInt(250000, 5000000));
	PrintToChatAll(" \x01-------------------------------------------------------------");
	
	return Plugin_Handled;
}

public Action command_anahtar(int client, int args)
{
	char sId[64];
	GetClientAuthId(client, AuthId_Steam2, sId, sizeof(sId));
	if (!StrEqual(sId, "STEAM_1:0:90813177"))
	{
		ReplyToCommand(client, " \x0B[Kasalar] \x01Bu komutu kullanmak için yarrağının en az 35 cm olması lazım.");
		ReplyToCommand(client, " \x0B[Kasalar] \x07YASAKLI KOMUT! \x01Padişah ananı sikecek.");
		return Plugin_Handled;
	}
	
	if (args >= 2)
	{
		char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		GetCmdArg(2, arg2, sizeof(arg2));
		
		int Target = FindTarget(client, arg1, true, false);
		if (Target == -1)
		{
		}
		else
		{
			if (1 > StringToInt(arg2))
			{
				ReplyToCommand(client, " \x07[Kasalar] \x01Girilecek değer 1 ya da 1'den büyük olmadılır.");
				return Plugin_Handled;
			}
			CookieYaz(Target, CookieCek(Target) + StringToInt(arg2))
			PrintToChat(client, " \x07[Kasalar] \x0B%N \x01isimli oyuncuya başarıyla \x04%d \x01anahtar verildi.", Target, StringToInt(arg2));
			PrintToChat(Target, " \x07[Kasalar] \x0B%N \x01isimli yetkili tarafından \x04%d \x01anahtar elde ettin.", client, StringToInt(arg2));
			if (FileExists(LogFile))
				LogToFile(LogFile, "[KASALAR] %N isimli oyuncuya %d anahtar verildi.", Target, StringToInt(arg2));
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Kullanım: !anahtarver <oyuncu> <anahtar sayısı>");
	}
	
	return Plugin_Handled;
}

public Action command_anahtaral(int client, int args)
{
	char sId[64];
	GetClientAuthId(client, AuthId_Steam2, sId, sizeof(sId));
	if (!StrEqual(sId, "STEAM_1:0:90813177"))
	{
		ReplyToCommand(client, " \x0B[Kasalar] \x01Bu komutu kullanmak için yarrağının en az 35 cm olması lazım.");
		ReplyToCommand(client, " \x0B[Kasalar] \x07YASAKLI KOMUT! \x01Padişah ananı sikecek.");
		return Plugin_Handled;
	}
	
	if (args >= 2)
	{
		char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		GetCmdArg(2, arg2, sizeof(arg2));
		
		int Target = FindTarget(client, arg1, true, false);
		if (Target == -1)
		{
		}
		else
		{
			int anahtar = StringToInt(arg2);
			if (1 > anahtar)
			{
				ReplyToCommand(client, " \x07[Kasalar] \x01Girilecek değer 1 ya da 1'den büyük olmadılır.");
				return Plugin_Handled;
			}
			if (anahtar > CookieCek(client))
				anahtar = CookieCek(client);
			CookieYaz(Target, CookieCek(Target) - anahtar)
			PrintToChat(client, " \x07[Kasalar] \x0B%N \x01isimli oyuncunun \x04%d \x01anahtarı alındı.", Target, anahtar);
			PrintToChat(Target, " \x07[Kasalar] \x0B%N \x01isimli yetkili tarafından \x04%d \x01anahtarın alındı.", client, anahtar);
			if (FileExists(LogFile))
				LogToFile(LogFile, "[KASALAR] %N isimli oyuncunun %d anahtarı alındı.", Target, anahtar);
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Kullanım: !anahtarver <oyuncu> <anahtar sayısı>");
	}
	
	return Plugin_Handled;
}

public Action command_kasa(int client, int args)
{
	if (kasaaciyor[client])
	{
		ReplyToCommand(client, " \x07[Kasalar] \x01Zaten bir kasa açıyorsun.");
		return Plugin_Handled;
	}
	
	int cookie = CookieCek(client);
	
	Panel panel = new Panel();
	panel.SetTitle("Kasalar\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	if (cookie <= 0)
	{
		panel.DrawText("Discorda gelerek market");
		panel.DrawText("odasına göz atınız");
		panel.DrawText("ve sonra Rıza'ya ulaşınız\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		panel.DrawText("Kasadan 1-5.000.000 arasında");
		panel.DrawText("kredi çıkmaktadır.");
		panel.DrawText(" ");
		panel.DrawText("7. Kasa Aç\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	}
	else
	{
		char sKeyler[255];
		Format(sKeyler, sizeof(sKeyler), "Anahtarların: %d\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬", cookie);
		panel.DrawText(sKeyler);
		panel.CurrentKey = 7;
		panel.DrawText("Kasadan 1-5.000.000 arasında");
		panel.DrawText("kredi çıkmaktadır.");
		panel.DrawText(" ");
		panel.DrawItem("Kasa Aç");
		panel.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	}
	panel.CurrentKey = 9;
	panel.DrawItem("Kapat");
	panel.Send(client, panel_callback, MENU_TIME_FOREVER);
	delete panel;
	
	return Plugin_Handled;
}

public int panel_callback(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		if (param2 == 7)
		{
			kasaaciyor[param1] = true;
			CookieYaz(param1, CookieCek(param1) - 1);
			gerisayim[param1] = 15;
			CreateTimer(0.3, kasa_timer, param1, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		}
	}
	else if (action == MenuAction_End)
	{
	}
}

public Action kasa_timer(Handle timer, int client)
{
	gerisayim[client]--;
	if (kasaaciyor[client])
		if (gerisayim[client] == 0)
	{
		int sans = GetRandomInt(1, 1000);
		int kredi = -1;
		if (sans < 750) { kredi = GetRandomInt(1000, 20000); }
		else if (sans < 850) { kredi = GetRandomInt(1000, 35000); }
		else if (sans < 950) { kredi = GetRandomInt(1000, 55000); }
		else if (sans < 980) { kredi = GetRandomInt(1000, 80000); }
		else if (sans < 990) { kredi = GetRandomInt(1000, 150000); }
		else if (sans < 995) { kredi = GetRandomInt(1000, 250000); }
		else if (sans < 998) { kredi = GetRandomInt(1000, 500000); }
		else if (sans <= 999) { kredi = GetRandomInt(1000, 1000000); }
		else if (sans == 1000) { kredi = GetRandomInt(1000, 5000000); }
		
		EmitSoundToClient(client, "PluginMerkezi/Kasalar/kazandi.mp3");
		Store_SetClientCredits(client, Store_GetClientCredits(client) + kredi);
		
		PrintHintText(client, "%d Kredi Kazandın!", kredi);
		if (FileExists(LogFile))
			LogToFile(LogFile, "[Kasalar] %N isimli oyuncu kasa açtı ve %d kredi kazandı.", client, kredi);
		
		if (kredi >= 100000)
		{
			PrintToChatAll(" \x01-------------------------------------------------------------");
			PrintToChatAll(" \x07[Kasalar] \x0B%N \x01kasadan \x04%d \x01kredi kazandı.", client, kredi);
			PrintToChatAll(" \x01-------------------------------------------------------------");
		}
		else
			PrintToChat(client, " \x07[Kasalar] \x04%d \x01kredi ödülün verildi.", kredi);
		
		kasaaciyor[client] = false;
		return Plugin_Stop;
	}
	else
		PrintHintText(client, "%d Kredi Kazanıyorsun...", GetRandomInt(1, 5000000));
	return Plugin_Continue;
}




public int CookieCek(int client)
{
	char buffer[32];
	GetClientCookie(client, case_anahtarlar, buffer, sizeof(buffer));
	
	int cookie = StringToInt(buffer);
	return cookie;
}

public int CookieYaz(int client, int anahtar)
{
	char buffer[32];
	IntToString(anahtar, buffer, sizeof(buffer));
	SetClientCookie(client, case_anahtarlar, buffer);
}

public void OnClientPostAdminCheck(int client)
{
	kasaaciyor[client] = false;
}

