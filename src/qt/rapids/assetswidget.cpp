#include "assetswidget.h"
#include "ui_assetswidget.h"

assetswidget::assetswidget(QWidget *parent) :
    QFrame(parent),
    ui(new Ui::assetswidget)
{
    ui->setupUi(this);
}

assetswidget::~assetswidget()
{
    delete ui;
}
