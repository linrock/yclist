require './models'

stuff = File.open('./tmp/cleaned-output.txt').read.split /\n/
for s in stuff do
  info = s.split "|"
  company = {
    :name     => info[1],
    # :class    => info[2],
    :dead     => info[4] == 'Y',
    :exited   => info[5] == 'Y',
    :url      => info[6]
  }
  Company.create(company)
end
