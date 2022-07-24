#ifndef ADJUSTER_H
#define ADJUSTER_H

#include <QObject>
#include <QTimer>
#include <QTime>
#include <QDebug>
#include <QString>
#include <QSettings>
#include <QJsonObject>
#include <QJsonValue>
#include <QLinkedList>
#include <QtWin>

#include <comdef.h>
#include <iostream>
#include <wbemidl.h>
#include <winbase.h>
#include <PhysicalMonitorEnumerationAPI.h>
#include <highlevelmonitorconfigurationapi.h>

using namespace std;

class Adjuster : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int cur_level READ cur_level WRITE set_level NOTIFY level_changed)
    Q_PROPERTY(QString get_adjust_label READ get_adjust_label WRITE set_adjust_label NOTIFY adjust_label_changed)
    Q_PROPERTY(QString get_status READ get_status WRITE set_status NOTIFY status_changed)
    Q_PROPERTY(bool get_state READ get_state WRITE set_state NOTIFY state_changed)
    Q_PROPERTY(QString get_initial_time READ get_initial_time WRITE set_initial_time NOTIFY initial_time_changed)
    Q_PROPERTY(QString get_current_time READ get_current_time WRITE set_current_time NOTIFY current_time_changed)
    Q_PROPERTY(QString get_target_time READ get_target_time WRITE set_target_time NOTIFY target_time_changed)
    Q_PROPERTY(QString get_error READ get_error WRITE set_error NOTIFY error_changed)

    private:

        //brightness custome functions
        void init_desktop_api();
        void init_laptop_api();
        void invalid_brightness(int *);
        void release_mem();
        void pc_mode();
        int get_desktop_brightness();
        int get_laptop_brightness();
        bool set_laptop_brightness(int);
        bool set_desktop_brightness(int);

        //custome functions
        bool is_end_of_day();
        bool day_adjust(int, int);
        bool night_adjust(int, int);
        bool in_range(bool mode = 0);
        bool rest_adjust();
        void stop();
        bool is_active();
        void start();
        QString get_stored_status(int);
        int get_settings(QString);        
        bool init_adjuster();
        void init_stopwatch();
        void start_stopwatch();
        void stop_stopwatch();
        QTime cal_target_time(bool mode = 0);
        bool in_day_range(QTime);
        bool in_night_range(QTime);
        void init_timers();
        void init_times();
        void init_settings();
        void init_components();
        void disable_timers(int target_timer = 0);
        void finish_adjusting(bool mode = 0);
        void set_activeness(bool);
        void set_internal_change(bool);
        bool is_internal_change();
        QString get_error_alias(int);

        //brightness variables for laptop
        IWbemLocator *pLocator = NULL;
        IWbemServices *pNamespace = 0;
        IEnumWbemClassObject *pEnum = NULL;
        IWbemClassObject *pObj;
        HRESULT hr = S_OK;
        BSTR path, ClassPath, bstrQuery;
        ULONG ulReturned;
        VARIANT var1;
        bool ret;

        //Day Variables
        QTimer *day_timer = NULL;

        //Night Varaibles
        QTimer *night_timer = NULL;

        //Macros
        #define INVALID -1

        //Variables
        QTimer *brightness_timer, *status_time, *watch_timer, *auto_adjust_timer;
        int brightness = INVALID;
        QTime current_time, target_time, initial_time,
        night_upr_lmt = QTime(19, 59, 59), night_lwr_lmt = QTime(16, 00, 0),
        day_upr_lmt = QTime(15, 59, 59), day_lwr_lmt = QTime(8, 00, 0);
        int g_level, last_max_brightness, last_min_brightness;
        bool PC = 0, active, enabled, internal_change;
        QString err_msg;
        QSettings *settings;
        QString status, adjust_label;

        // brightness variables for desktop
        HANDLE handle = NULL;
        LPPHYSICAL_MONITOR pointerToPhysicalMonitors = NULL;
        HMONITOR monitorHandler = NULL;
        HWND windowHandler = NULL;
        DWORD numberOfMonitors, minBrightnessLevel = 0,
        maxBrightnessLevel = 0 ,curBrightnessLevel = 0,
        defaultMinBrightnessLevel = 0, defaultCurBrightnessLevel = 0,
        defaultMaxBrightnessLevel = 0;

    private slots:
        void inc_brightness();
        void dec_brightness();
        void remove_status();

    public:

        explicit Adjuster(QObject *parent = 0);    
        ~Adjuster();
        // brightness api functions
        Q_INVOKABLE int get_brightness();
        Q_INVOKABLE bool set_brightness(int);
        Q_INVOKABLE void adjust();

        // settings handler
        Q_INVOKABLE void save(QJsonObject);
        Q_INVOKABLE QVariant load();
        Q_INVOKABLE QString get_err_msg();

        // status handler
        Q_INVOKABLE void init_status(int);

    public slots:
        void update_slider();
        int cur_level();
        void set_level(int);
        QString get_status();
        void set_status(QString);
        bool get_state();
        void set_state(bool);
        QString get_current_time();
        void set_current_time(QString);
        QString get_target_time();
        void set_initial_time(QString);
        QString get_initial_time();
        void set_target_time(QString);
        void start_ticking();
        void start_adjusting();
        void auto_adjust();
        QString get_adjust_label();
        void set_adjust_label(QString);
        void set_error(QString);
        QString get_error();

    signals:
        void level_changed(int);
        void status_changed(QString);
        void state_changed(bool);
        void current_time_changed(QTime);
        void target_time_changed(QTime);
        void initial_time_changed(QTime);
        void adjust_label_changed(QString);
        void error_changed(QString);
};

#endif // ADJUSTER_H
