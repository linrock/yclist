from elixir import *
import os


class Company(Entity):
    using_table_options(useexisting=True)
    using_options(tablename='companies')

    has_field('name',           String(32), index=True)
    has_field('class_year',     String(128))
    has_field('url',            String(128))
    has_field('title',          String(128))
    has_field('meta_desc',      String(128))

    has_field('dead',           Boolean)
    has_field('exited',         Boolean)
    has_field('favicon',        Boolean)
    has_field('snapshot',       Boolean)

    def convert_favicon(self):
        directory = 'public/%s' % self.url[7:]
        if 'favicon.ico' in os.listdir(directory):
            self.favicon = True
            old_icon = '"%s/favicon.ico[0]"' % directory
            new_icon = '%s/favicon.png' % directory
            if not os.path.isfile(new_icon):
                os.system('convert %s -resize 16x16 %s' % (old_icon, new_icon))
        else:
            self.favicon = False
        session.commit()


metadata.bind = 'sqlite:///data.sqlite'
metadata.bind.echo = False
setup_all(True)
