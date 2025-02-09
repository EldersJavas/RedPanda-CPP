#ifndef PROJECTCOMPILER_H
#define PROJECTCOMPILER_H

#include "compiler.h"
#include <QObject>

class Project;
class ProjectCompiler : public Compiler
{
    Q_OBJECT
public:
    ProjectCompiler(std::shared_ptr<Project> project, bool silent,bool onlyCheckSyntax);
    void buildMakeFile();

    bool onlyClean() const;
    void setOnlyClean(bool newOnlyClean);

private:
    void createStandardMakeFile();
    void createStaticMakeFile();
    void createDynamicMakeFile();
    void newMakeFile(QFile& file);
    void writeMakeHeader(QFile& file);
    void writeMakeDefines(QFile& file);
    void writeMakeTarget(QFile& file);
    void writeMakeIncludes(QFile& file);
    void writeMakeClean(QFile& file);
    void writeMakeObjFilesRules(QFile& file);
    void writeln(QFile& file, const QString& s="");
    // Compiler interface
private:
    bool mOnlyClean;
protected:
    bool prepareForCompile() override;
    QString pipedText() override;
    bool prepareForRebuild() override;
};

#endif // PROJECTCOMPILER_H
