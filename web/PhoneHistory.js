const d3 = require('d3');

const render = (data) => {
  console.log(data);

  const parsed = data.facebook_time_spent.map(d => {
    const [h, m, s] = d[1].split(':');

    return {
      date: Date.parse(d[0]),
      duration: parseInt(s) + (60 * (parseInt(m) + (60 * parseInt(h)))),
    }
  });

  const graph = d3.select('#app')
  const width = 600;
  const height = 150;
  const axisSize = 20;

  graph.append('h2').text(d => `foo`);

  const svg = graph.append('svg');

  const startOfData = new Date('2016-12-31');

  const x = d3.scaleTime()
    .domain(d3.extent(parsed, d => d.date))
    .range([axisSize, width]);

  const y = d3.scaleLinear()
    .domain(d3.extent(parsed, d => d.duration))
    .range([height, 0]);

  const line = d3.line()
    .x(d => x(d.date))
    .y(d => y(d.duration))

  svg
    .attr('width', width)
    .attr('height', height)

  svg.append('path')
    .data([parsed])
    .attr('style', 'fill: none; stroke: blue; stroke-width: 3px')
    .attr('d', line)

  const xAxis = d3.axisBottom(x).ticks(3);
  svg.append('g')
    .attr('transform', `translate(0, ${height - axisSize + 2})`) // 2px of padding
    .call(xAxis);

  const yAxis = d3.axisLeft(y).tickValues([1800, 3600]).tickSize(width);
  svg.append('g')
    .attr('transform', `translate(${width + axisSize}, 0)`)
    .call(yAxis);
}

document.addEventListener('DOMContentLoaded', () => {
  d3.json('/api/builder/PhoneUsage').get(render);
});
