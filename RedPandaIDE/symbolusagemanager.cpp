#include "symbolusagemanager.h"
#include "settings.h"
#include "systemconsts.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMessageBox>

SymbolUsageManager::SymbolUsageManager(QObject *parent) : QObject(parent)
{

}

void SymbolUsageManager::load()
{
    QString filename = includeTrailingPathDelimiter(pSettings->dirs().config())
            + DEV_SYMBOLUSAGE_FILE;
    if (!fileExists(filename))
        return;
    QFile file(filename);
    if (!file.open(QFile::ReadOnly)) {
        QMessageBox::critical(nullptr,
                              tr("Load symbol usage info failed"),
                              tr("Can't open symbol usage file '%1' for read.")
                              .arg(filename));
    }
    QByteArray contents = file.readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(contents,&error);
    if (error.error != QJsonParseError::NoError) {
        QMessageBox::critical(nullptr,
                              tr("Load symbol usage info failed"),
                              tr("Can't parse symbol usage file '%1': %2")
                              .arg(filename)
                              .arg(error.errorString()));
    }

    mUsages.clear();
    QJsonArray array = doc.array();
    foreach (const QJsonValue& val, array) {
        QJsonObject obj = val.toObject();
        QString fullname = obj["symbol"].toString();
        int count = obj["count"].toInt();
        PSymbolUsage usage = std::make_shared<SymbolUsage>();
        usage->fullName = fullname;
        usage->count = count;
        mUsages.insert(fullname,usage);
    }
}

void SymbolUsageManager::save()
{
    QString filename = includeTrailingPathDelimiter(pSettings->dirs().config())
            + DEV_SYMBOLUSAGE_FILE;
    QFile file(filename);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)) {
        QMessageBox::critical(nullptr,
                              tr("Save symbol usage info failed"),
                              tr("Can't open symbol usage file '%1' for write.")
                              .arg(filename));
    }
    QJsonArray array;
    foreach (const PSymbolUsage& usage,mUsages) {
        QJsonObject object;
        object["symbol"]=usage->fullName;
        object["count"]=usage->count;
        array.append(object);
    }
    QJsonDocument doc;
    doc.setArray(array);
    if (file.write(doc.toJson())<0) {
        QMessageBox::critical(nullptr,
                              tr("Save symbol usage info failed"),
                              tr("Write to symbol usage file '%1' failed.")
                              .arg(filename));
    }
}

void SymbolUsageManager::reset()
{
    mUsages.clear();
    save();
}

PSymbolUsage SymbolUsageManager::findUsage(const QString &fullName) const
{
    return mUsages.value(fullName,PSymbolUsage());
}

void SymbolUsageManager::updateUsage(const QString &symbol, int count)
{
    PSymbolUsage usage = mUsages.value(symbol,PSymbolUsage());
    if (usage) {
        usage->count = count;
    } else {
        usage = std::make_shared<SymbolUsage>();
        usage->fullName = symbol;
        usage->count = count;
        mUsages.insert(symbol,usage);
    }
}
