#include <QApplication>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QDebug>
#include <QQmlContext>
#include "adjuster.h"

int main(int argc, char *argv[])
{

    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    // app code
    app.setWindowIcon(QIcon(":/files/images/adjuster.png"));
    Adjuster adj;
    engine.rootContext()->setContextProperty("adj", &adj);
    return app.exec();
}
