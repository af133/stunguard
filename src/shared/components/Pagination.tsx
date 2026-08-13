import { ChevronLeft, ChevronRight } from 'lucide-react';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  totalData: number;
  itemsPerPage: number;
  onPageChange: (page: number) => void;
}

const Pagination = ({ currentPage, totalPages, totalData, itemsPerPage, onPageChange }: PaginationProps) => {
  const startItem = (currentPage - 1) * itemsPerPage + 1;
  const endItem = Math.min(currentPage * itemsPerPage, totalData);

  const getPageNumbers = () => {
    const pages: (number | '...')[] = [];
    if (totalPages <= 5) {
      for (let i = 1; i <= totalPages; i++) pages.push(i);
    } else {
      pages.push(1);
      if (currentPage > 3) pages.push('...');
      for (let i = Math.max(2, currentPage - 1); i <= Math.min(totalPages - 1, currentPage + 1); i++) {
        pages.push(i);
      }
      if (currentPage < totalPages - 2) pages.push('...');
      pages.push(totalPages);
    }
    return pages;
  };

  return (
    <div className="flex items-center justify-between pt-4 px-1">
      <p className="text-sm text-gray-500">
        Menampilkan <span className="font-semibold text-gray-700">{startItem}-{endItem}</span> dari{' '}
        <span className="font-semibold text-gray-700">{totalData.toLocaleString('id-ID')}</span> data
      </p>

      <div className="flex items-center gap-1">
        <button
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1}
          className="p-1.5 rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          aria-label="Halaman sebelumnya"
        >
          <ChevronLeft size={16} />
        </button>

        {getPageNumbers().map((page, i) =>
          page === '...' ? (
            <span key={`dots-${i}`} className="px-2 text-sm text-gray-400">…</span>
          ) : (
            <button
              key={page}
              onClick={() => onPageChange(page as number)}
              className={`w-8 h-8 rounded-lg text-sm font-medium transition ${
                page === currentPage
                  ? 'bg-green-800 text-white shadow-sm'
                  : 'text-gray-600 hover:bg-gray-100'
              }`}
            >
              {page}
            </button>
          )
        )}

        <button
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
          className="p-1.5 rounded-lg border border-gray-200 text-gray-500 hover:bg-gray-50 disabled:opacity-40 disabled:cursor-not-allowed transition"
          aria-label="Halaman berikutnya"
        >
          <ChevronRight size={16} />
        </button>
      </div>
    </div>
  );
};

export default Pagination;
