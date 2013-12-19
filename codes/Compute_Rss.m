function Rss = Compute_Rss(target, RssBeaconCoordinates)

%compute RSS for single location with x,y coordinates
%target: [x,y]
%RssBeaconCoordinates:[M,2],beacon number: M

%Rss returns a M*1 vector

[M,N]=size(RssBeaconCoordinates);

Dis = [];
Rss = [];
for i = 1:M
    x1 = target(1);
    y1 = target(2);
    x2 = RssBeaconCoordinates(i,1);
    y2 = RssBeaconCoordinates(i,2);
    dis = sqrt((x1-x2)^2+(y1-y2)^2);
    Dis = [Dis; dis];
end

Rss = PropModel(Dis);