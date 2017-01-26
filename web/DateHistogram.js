const d3 = require('d3');

const sortFn = (a, b) => {
  return a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : a[0] >= b[0] ? 0 : NaN;
};

const render = (data) => {
  const width = 1000;
  const height = 100;
  const axisHeight = 40;

  const dataArray = Object.keys(data).map(name => {
    const values = Object.keys(data[name])
      .map(date => [date, data[name][date]])
      .sort(sortFn);

    return [name, values];
  });

  const now = new Date();
  const oneYearAgo = new Date();
  oneYearAgo.setFullYear(now.getFullYear() - 1);

  const x = d3.scaleTime()
    .domain([oneYearAgo, now])
    .range([0, width]);

  const graph =
    d3.select('#app')
      .selectAll('p')
      .data(dataArray)
      .enter()
        .append('div');

  graph
    .append('h2')
    .text(d => `${d[0]} (last: ${d3.max(d[1].map(d2 => d2[0]))})`);

  const svg = graph.append('svg');

  // 1. render the data
  svg
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .selectAll('rect')
    .data(d => d[1])
    .enter()
      .append('rect')
      .attr('x', d => x(Date.parse(d[0])))
      .attr('y', 0)
      .attr('height', height - axisHeight)
      .attr('width', width / 365)
      .attr('opacity', d => d[1] * 0.2)

  // 2. render the x axis
  const axis = d3.axisBottom(x);
  svg.append('g')
    .attr('transform', `translate(0, ${height - axisHeight + 2})`) // 2px of padding
    .call(axis);
};

document.addEventListener('DOMContentLoaded', () => {
  d3.json('/api/date_histogram').get(render);
});
