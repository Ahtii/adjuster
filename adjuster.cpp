#include "adjuster.h"

bool Adjuster::init_adjuster(){
    pc_mode();    
    init_timers();
    init_settings();
    init_times();
    init_stopwatch();
    init_components();
    return true;
}

Adjuster::Adjuster(QObject *parent) : QObject(parent)
{      
    init_adjuster();
}

Adjuster::~Adjuster(){
    brightness_timer->stop();
}

// setup time
void Adjuster::init_times(){
    set_current_time("00:00:00");
    set_target_time("00:00:00");
    set_initial_time("00:00:00");
}

// setup settings
void Adjuster::init_settings(){
    settings = new QSettings("Belivers","Adjuster");
}

// setup timers
void Adjuster::init_timers(){
    brightness_timer = new QTimer(this);
    QObject::connect(brightness_timer, &QTimer::timeout,this,&Adjuster::update_slider);
    brightness_timer->start(400);
    auto_adjust_timer = new QTimer(this);
    connect(auto_adjust_timer,SIGNAL(timeout()),this,SLOT(auto_adjust()));
}

// start ticking from current time

void Adjuster::start_ticking(){
    set_current_time(current_time.addSecs(1).toString());
}

void Adjuster::init_stopwatch(){
    watch_timer = new QTimer(this);
    connect(watch_timer, SIGNAL(timeout()), this, SLOT(start_ticking()));
}

// initiate components

void Adjuster::init_components(){
    set_level(get_brightness());
    set_adjust_label("Go");
    set_error("");
    set_status("");
    set_state(true);
    set_activeness(false);
    set_internal_change(false);
}

QString Adjuster::get_error_alias(int alias){
    // 1XXX for general, 2XXX for laptop, 3XXX for desktop
    switch(alias){
        case 1050:
             return "Error 1050: Failed to get system brightness.";
        case 3050:
             return "Error 1051: Failed to get DDC/CI, Please check if it is enabled.";
        case 3051:
             return "Error 1052: Failed to get number of monitors.";
        case 3052:
             return "Error 1053: Failed to get monitor.";
        case 3053:
             return "Error 1054: Failed to get the monitor handle.";
        default:
                return "";
    }
}

void Adjuster::set_internal_change(bool change){
    if (change != internal_change)
        internal_change = change;
}

bool Adjuster::is_internal_change(){
    return internal_change;
}

void Adjuster::auto_adjust(){
    if (in_day_range(current_time) || in_night_range(current_time))
        start_adjusting();

}

void Adjuster::set_error(QString msg){
    if (msg != err_msg){
        err_msg = msg;
        qDebug() << "Error: " << get_error();
        emit error_changed(msg);
        if (is_active())
            stop();
    }
}

QString Adjuster::get_error(){
    return err_msg;
}

// save app settings

void Adjuster::save(QJsonObject new_settings){

    settings->beginGroup("Evening Settings");
    settings->setValue("e_level",new_settings.value("e_level").toInt());
    settings->setValue("e_time",new_settings.value("e_time").toInt());
    settings->endGroup();

    settings->beginGroup("Morning Settings");
    settings->setValue("m_level",new_settings.value("m_level").toInt());
    settings->setValue("m_time",new_settings.value("m_time").toInt());
    settings->endGroup();

    settings->beginGroup("Other Settings");
    settings->setValue("min",new_settings.value("min").toInt());
    settings->setValue("max",new_settings.value("max").toInt());
    settings->endGroup();
}

// load app settings

QVariant Adjuster::load(){
    QJsonObject settings_vars;
    settings->beginGroup("Evening Settings");
    settings_vars.insert("e_level",settings->value("e_level",5).toInt());
    settings_vars.insert("e_time",settings->value("e_time",60).toInt());
    settings->endGroup();

    settings->beginGroup("Morning Settings");
    settings_vars.insert("m_level",settings->value("m_level",5).toInt());
    settings_vars.insert("m_time",settings->value("m_time",60).toInt());
    settings->endGroup();

    settings->beginGroup("Other Settings");
    settings_vars.insert("min",settings->value("min",20).toInt());
    settings_vars.insert("max",settings->value("max",80).toInt());
    settings->endGroup();

    return settings_vars;
}

// get app settings

int Adjuster::get_settings(QString key){

    if (key.contains("m_"))
        settings->beginGroup("Morning Settings");
    else if (key.contains("e_"))
        settings->beginGroup("Evening Settings");
    else
        settings->beginGroup("Other Settings");

    int value = settings->value(key).toInt();
    settings->endGroup();
    return value;
}

// initialize for desktop brightness
void Adjuster::init_desktop_api(){
    windowHandler = GetDesktopWindow() ;
    monitorHandler = MonitorFromWindow(windowHandler, MONITOR_DEFAULTTOPRIMARY) ;
    BOOL bSuccess ;
    if (monitorHandler == NULL)
        set_error(get_error_alias(3053));
    else {
        bSuccess = GetNumberOfPhysicalMonitorsFromHMONITOR(monitorHandler,&numberOfMonitors) ;
        if (bSuccess) {

            pointerToPhysicalMonitors = (LPPHYSICAL_MONITOR)malloc(
                      numberOfMonitors* sizeof(PHYSICAL_MONITOR) ) ;
            if (pointerToPhysicalMonitors != NULL) {
                bSuccess = GetPhysicalMonitorsFromHMONITOR(
                            monitorHandler,numberOfMonitors,
                            pointerToPhysicalMonitors) ;
                handle = pointerToPhysicalMonitors[1].hPhysicalMonitor ;
                //LPDWORD min, max, cur;
                //qDebug() << GetMonitorBrightness(handle, min, cur, max);
            }else
                set_error(get_error_alias(3052));
        }else
            set_error(get_error_alias(3051));
    }
}

// check if this pc is desktop or laptop
void Adjuster::pc_mode(){
    SYSTEM_POWER_STATUS power_status;
    BOOL ret = GetSystemPowerStatus(&power_status);
    if (ret && power_status.ACLineStatus == 255){
        PC = 1;    // working with Desktop
        init_desktop_api();
    }
}

// start: adjust brightness slider to latest brightness
void Adjuster::update_slider(){
    int brightness = get_brightness();
    if (brightness != INVALID)
        set_level(brightness);
}

void Adjuster::set_level(int level){
    if (level != brightness){
        brightness = level;
        emit level_changed(level);
        if (is_active()){
            if (!is_internal_change())
                stop();
             else
                set_internal_change(false);
        }
    }
}

int Adjuster::cur_level() {
    return brightness;
}
// end: adjust brightness slider to latest brightness

// start: configure WMI for brightness manipulation
void Adjuster::init_laptop_api(){

    hr = CoInitialize(0);
    if (FAILED(hr))
        return;
    hr = CoInitializeSecurity(NULL, INVALID, NULL, NULL,
                RPC_C_AUTHN_LEVEL_PKT_PRIVACY,
                RPC_C_IMP_LEVEL_IMPERSONATE,
                NULL,
                EOAC_SECURE_REFS,
                NULL);

    hr = CoCreateInstance(CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER,
                          IID_IWbemLocator, (LPVOID *) &pLocator);
    if (FAILED(hr))
        return;
    hr = pLocator->ConnectServer(path, NULL, NULL, NULL, 0, NULL, NULL, &pNamespace);
    if (hr != WBEM_S_NO_ERROR)
        return;
    hr = CoSetProxyBlanket(pNamespace,
                           RPC_C_AUTHN_WINNT,
                           RPC_C_AUTHN_NONE,
                           NULL,
                           RPC_C_AUTHN_LEVEL_PKT,
                           RPC_C_IMP_LEVEL_IMPERSONATE,
                           NULL,
                           EOAC_NONE
                );    
    if (hr != WBEM_S_NO_ERROR)
        return;
    hr = pNamespace->ExecQuery(_bstr_t(L"WQL"),
                               bstrQuery,
                               WBEM_FLAG_RETURN_IMMEDIATELY,
                               NULL,
                               &pEnum
                               );
    if (hr != WBEM_S_NO_ERROR)
        return;
    hr = WBEM_S_NO_ERROR;
}

void Adjuster::release_mem(){

    SysFreeString(path);
    SysFreeString(ClassPath);
    SysFreeString(bstrQuery);

    if (pLocator)
        pLocator->Release();

    if (pNamespace)
        pNamespace->Release();

    CoUninitialize();
}

void Adjuster::invalid_brightness(int *brightness){
    if (*brightness == INVALID){                
        set_error(get_error_alias(1050));
        brightness = 0;
    }
}

int Adjuster::get_desktop_brightness(){

    DWORD min = 0, cur = INVALID, max = 0;
    if (!GetMonitorBrightness(handle, &min, &cur, &max)){        
        set_error(get_error_alias(3050));
    }
    int brightness = cur;
    invalid_brightness(&brightness);
    return brightness;
}

int Adjuster::get_laptop_brightness(){

    int brightness = INVALID;

    path = SysAllocString(L"root\\wmi");
    ClassPath = SysAllocString(L"WmiMonitorBrightness");
    bstrQuery = SysAllocString(L"Select * from WmiMonitorBrightness");

    if (!path || !ClassPath){
        goto cleanup;
    }

    init_laptop_api();

    if (hr != WBEM_S_NO_ERROR)
        goto cleanup;

    while (WBEM_S_NO_ERROR == hr){

        hr = pEnum->Next(WBEM_INFINITE,
                         1,
                         &pObj,
                         &ulReturned
                         );
        if (hr != WBEM_S_NO_ERROR){
            goto cleanup;
        }

        hr = pObj->Get(_bstr_t(L"CurrentBrightness"), 0, &var1, NULL, NULL);
        brightness = V_UI1(&var1);
        VariantClear(&var1);
        if (hr != WBEM_S_NO_ERROR){
            goto cleanup;
        }        
    }

    cleanup:
        release_mem();

    invalid_brightness(&brightness);
    return brightness;
}

int Adjuster::get_brightness(){
    if (PC)
        return get_desktop_brightness();
    else
        return get_laptop_brightness();
}

// brightness for laptop
bool Adjuster::set_laptop_brightness(int val){

    ret = true;

    path = SysAllocString(L"root\\wmi");
    ClassPath = SysAllocString(L"WmiMonitorBrightnessMethods");
    BSTR MethodName = SysAllocString(L"WmiSetBrightness");
    BSTR ArgName0 = SysAllocString(L"Timeout");
    BSTR ArgName1 = SysAllocString(L"Brightness");
    bstrQuery = SysAllocString(L"Select * from WmiMonitorBrightnessMethods");
    IWbemClassObject *pInClass = NULL, *pInInst = NULL, *pClass = NULL;

    if (!path || !ClassPath || !MethodName || !ArgName0){
        ret = false;        
        goto cleanup;
    }

    init_laptop_api();

    if (hr != WBEM_S_NO_ERROR){
        ret = false;        
        goto cleanup;
    }
    while(WBEM_S_NO_ERROR == hr){

        hr = pEnum->Next(WBEM_INFINITE,
                         1,
                         &pObj,
                         &ulReturned);
        if (hr != WBEM_S_NO_ERROR){
            ret = false;            
            goto cleanup;
        }
        hr = pNamespace->GetObject(ClassPath, 0, NULL, &pClass, NULL);        
        if (hr != WBEM_S_NO_ERROR){
            ret = false;           
            goto cleanup;
        }       
        hr = pClass->GetMethod(MethodName, 0, &pInClass, NULL);
        if (hr != WBEM_S_NO_ERROR){
            ret = false;            
            goto cleanup;
        }
        hr = pInClass->SpawnInstance(0, &pInInst);
        if (hr != WBEM_S_NO_ERROR){
            ret = false;            
            goto cleanup;
        }
        VariantInit(&var1);        
        V_VT(&var1) = VT_BSTR;
        V_BSTR(&var1) = SysAllocString(L"0");
        hr = pInInst->Put(ArgName0, 0, &var1, CIM_UINT32);        
        VariantClear(&var1);
        if (hr != WBEM_S_NO_ERROR){
            ret = false;            
            goto cleanup;
        }        
        VARIANT var;
        VariantInit(&var);        
        V_VT(&var) = VT_BSTR;
        WCHAR buf[10] = {0};        
        wsprintfW(buf, L"%1d", val);        
        V_BSTR(&var) = SysAllocString(buf);
        hr = pInInst->Put(ArgName1, 0, &var, CIM_UINT8);        
        VariantClear(&var);
        if (hr != WBEM_S_NO_ERROR){
            ret = false;            
            goto cleanup;
        }        
        VARIANT pathVariable;
        VariantInit(&pathVariable);

        hr = pObj->Get(_bstr_t(L"__PATH"), 0, &pathVariable, NULL, NULL);
        if (hr != WBEM_S_NO_ERROR){
            ret = false;            
            goto cleanup;
        }
        hr = pNamespace->ExecMethod(pathVariable.bstrVal, MethodName, 0, NULL, pInInst, NULL, NULL);        
        VariantClear(&pathVariable);
        if (hr != WBEM_S_NO_ERROR){
            ret = false;            
            goto cleanup;
        }
    }
    cleanup:

        release_mem();

        SysFreeString(MethodName);
        SysFreeString(ArgName0);
        SysFreeString(ArgName1);

        if (pClass)
            pClass->Release();

        if (pInInst)
            pInInst->Release();

        if (pInClass)
            pInClass->Release();

        return ret;
}

// set brightness for desktop
bool Adjuster::set_desktop_brightness(int val){
    bool response = false;
    if (SetMonitorBrightness(handle, val))
        response = true;
    return response;
}

// set brightness for laptop
bool Adjuster::set_brightness(int val){

    if (PC)
        return set_desktop_brightness(val);
    else
        return set_laptop_brightness(val);    
}

// get current time of adjust mode

QString Adjuster::get_current_time(){
    return current_time.toString();
}

// set current time of adjust mode

void Adjuster::set_current_time(QString str){
    QTime time = time.fromString(str);
    if (current_time != time){
        current_time = time;
        emit current_time_changed(time);
    }
}

// get target time of adjust mode

QString Adjuster::get_target_time(){
    return target_time.toString();
}

// set target time of adjust mode

void Adjuster::set_target_time(QString str){
    QTime time = time.fromString(str);
    if (target_time != time){
        target_time = time;
        emit target_time_changed(time);
    }
}

// get initial time of adjust mode
QString Adjuster::get_initial_time(){
    return initial_time.toString();
}

// set initial time of adjust mode
void Adjuster::set_initial_time(QString str){
    QTime time = time.fromString(str);
    if (initial_time != time){
        initial_time = time;
        emit initial_time_changed(time);
    }
}

// under day range

bool Adjuster::in_day_range(QTime time){
     if (time.secsTo(day_lwr_lmt) <= 0 && time.secsTo(day_upr_lmt) >= 0)
         return true;
     return false;
}

// under night range

bool Adjuster::in_night_range(QTime time){
     if (time.secsTo(night_lwr_lmt) <= 0 && time.secsTo(night_upr_lmt) >= 0)
         return true;
     return false;
}

// calculate target time

QTime Adjuster::cal_target_time(bool mode){
    QTime time = current_time;
    int brightness = get_brightness();
    if (mode){
        int min = get_settings("min"), range = get_settings("e_time"), level = get_settings("e_level");
        if (brightness < min ){
            if (brightness != INVALID){
                set_brightness(min);
                brightness = min;
            }else{
                set_error(get_error_alias(1050));
                return QTime(0,0,0);
            }
        }
        for(;time.secsTo(night_upr_lmt) > 0 && brightness >= min; time = time.addSecs(range * 60), brightness -= level);
        time = time.addSecs(- (range * 60));
        last_min_brightness = brightness + level;
    }else{
        int max = get_settings("max"), range = get_settings("m_time"), level = get_settings("m_level");
        if (brightness > max ){
            set_brightness(max);
            brightness = max;
        }else if (brightness == INVALID){
            set_error(get_error_alias(1050));
            return QTime(0,0,0);
        }
        for(;time.secsTo(day_upr_lmt) > 0 && brightness <= max; time = time.addSecs(range * 60), brightness += level);
        time = time.addSecs(- (range * 60));
        last_max_brightness = brightness - level;
    }
    return time;
}

// check to see if current time is in day or night range
bool Adjuster::in_range(bool mode){    
    disable_timers(3);
    set_current_time(QTime::currentTime().toString());
    set_initial_time(QTime::currentTime().toString());
    QTime time;
    if (mode){
        if (!in_night_range(current_time))
            return false;
        time = cal_target_time(mode);
    }else{        
        if (!in_day_range(current_time))
            return false;
        time = cal_target_time();
    }
    if (!time.secsTo(current_time) || time.secsTo(current_time) > 0){
        time = QTime(0,0,0);
        return false;
    }
    set_target_time(time.toString());
    return true;
}

void Adjuster::finish_adjusting(bool mode){
    if (mode){
        disable_timers(2);
        set_brightness(get_settings("min"));
    }else{
        disable_timers(1);
        set_brightness(get_settings("max"));
    }
    stop_stopwatch();
}

void Adjuster::inc_brightness(){
    int brightness = get_brightness();        
    if (brightness != INVALID){
        int max = get_settings("max");
        int brightness = get_brightness();
        if (brightness < max && in_day_range(current_time)){
            brightness += g_level;
            if (brightness <= max){
                set_internal_change(true);
                set_brightness(brightness);                                
                if (last_max_brightness == brightness)
                    finish_adjusting();
                return;
            }
        }
    }else
        set_error(get_error_alias(1050));
    finish_adjusting();
}

QString Adjuster::get_err_msg(){
    return err_msg;
}

bool Adjuster::day_adjust(int level, int range){    
    int brightness = get_brightness();
    if (brightness != INVALID){
        g_level = level;
        day_timer = new QTimer(this);
        connect(day_timer, SIGNAL(timeout()), this, SLOT(inc_brightness()));        
        day_timer->start(range * 60000);
        return true;
    }
    set_error(get_error_alias(1050));
    return false;
}

void Adjuster::dec_brightness(){
    int brightness = get_brightness();
    if (brightness != INVALID){
        int min = get_settings("min");
        if (brightness > min && in_night_range(current_time)){
            brightness -= g_level;
            if (brightness >= min){
                set_internal_change(true);
                set_brightness(brightness);
                if (last_min_brightness == brightness)
                    finish_adjusting(1);
                return;
            }
        }
    }else
        set_error(get_error_alias(1050));
    finish_adjusting(1);
}

bool Adjuster::night_adjust(int level, int range){    
    int brightness = get_brightness();
    if (brightness != INVALID){
        g_level = level;
        night_timer = new QTimer(this);                
        connect(night_timer, SIGNAL(timeout()), this, SLOT(dec_brightness()));
        night_timer->start(range * 60000);
        return true;
    }
    set_error(get_error_alias(1050));
    return false;
}

QString Adjuster::get_adjust_label(){
    return adjust_label;
}

bool Adjuster::rest_adjust(){
    if (!in_day_range(current_time) && !in_night_range(current_time))
        set_brightness(40);    
    stop_stopwatch();
    if (!auto_adjust_timer->isActive())
        auto_adjust_timer->start(1000);
    return true;
}

// set label to adjusting mode

void Adjuster::set_adjust_label(QString label){
    if (label != adjust_label){
        adjust_label = label;
        emit adjust_label_changed(label);
    }
}

// get control enability
bool Adjuster::get_state(){
    return enabled;
}

// set control enability

void Adjuster::set_state(bool state){
    if (state != enabled){
        enabled = state;
        emit state_changed(state);
    }
}

// stop the current time ticking

void Adjuster::stop_stopwatch(){
    if (watch_timer){
        if (watch_timer->isActive())
            watch_timer->stop();
    }
    set_current_time("00:00:00");
    set_target_time("00:00:00");
    set_initial_time("00:00:00");
}

// disable a particular or all timers

void Adjuster::disable_timers(int target_timer){

    switch(target_timer){
        case 1:
            if(day_timer)
               if (day_timer->isActive())
                   day_timer->stop();
            break;
        case 2:
            if(night_timer)
               if (night_timer->isActive())
                   night_timer->stop();
            break;
        case 3:
            if(auto_adjust_timer)
               if (auto_adjust_timer->isActive())
                   auto_adjust_timer->stop();
            break;
        default:
            if (night_timer){
                if (night_timer->isActive())
                    night_timer->stop();
            }else if(day_timer)
                if (day_timer->isActive())
                    day_timer->stop();
            if (auto_adjust_timer)
                if (auto_adjust_timer->isActive())
                    auto_adjust_timer->stop();
    }
}

// stop the adjusting mode

void Adjuster::stop(){
    qDebug() << "working...!";
    disable_timers();
    set_activeness(false);
    set_adjust_label("Go");    
    set_state(true);
    stop_stopwatch();
}

// check to see if adjusting mode is running

bool Adjuster::is_active(){
    return active;
}

// set the active state of adjuster

void Adjuster::set_activeness(bool state){
    if (state != active)
        active = state;
}

// create a stopwatch for current time

void Adjuster::start_stopwatch(){
    watch_timer->start(1000);
}

// start adjusting mode

void Adjuster::start(){
    set_activeness(true);
    set_adjust_label("stop");   
    set_state(false);
    start_stopwatch();
}

// start adjusting the brightness

void Adjuster::start_adjusting(){    
    if (in_range())
        day_adjust(get_settings("m_level"), get_settings("m_time"));
    else if (in_range(1))
        night_adjust(get_settings("e_level"), get_settings("e_time"));
    else
        rest_adjust();
}

// controller of adjusting mode

void Adjuster::adjust(){
    if (is_active()){
        stop();
    }else{
        start();
        start_adjusting();
    }
}
// end: peroidically adjust brightness with current time

// get current status

QString Adjuster::get_status(){
    return status;
}

// get stored status

QString Adjuster::get_stored_status(int choices){

    QString new_status;

    if (choices == 1)
        new_status = "Saved.";
    else if (choices == 2)
        new_status = "Default applied.";
    else if (choices == 3)
        if (is_active())
            new_status = "Adjuster started.";
        else
            new_status = "Adjuster stopped.";
    else
        new_status = "";

    return new_status;
}

// set status

void Adjuster::set_status(QString new_status){
    status = new_status;
    emit status_changed(status);
}

// remove status after specified time

void Adjuster::remove_status(){
    status_time->stop();
    set_status(get_stored_status(0));    
}

// initialize status

void Adjuster::init_status(int choices){
    QString status = get_stored_status(choices);
    set_status(status);
    status_time = new QTimer(this);
    connect(status_time, SIGNAL(timeout()), this, SLOT(remove_status()));
    status_time->start(2000);
}
