# Generated by Django 5.2 on 2025-04-28 16:24

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('backup', '0002_mikrotikdevice_dns_alter_mikrotikdevice_ip_address_and_more'),
    ]

    operations = [
        migrations.RenameField(
            model_name='mikrotikdevice',
            old_name='port',
            new_name='api_port',
        ),
        migrations.AddField(
            model_name='mikrotikdevice',
            name='ssh_port',
            field=models.IntegerField(default=22),
        ),
    ]
